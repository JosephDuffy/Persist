import Foundation
#if canImport(Combine)
import Combine
#endif

/**
 An object that can store and retrieve values from a `Storage` instance, optionally passing values through a
 transformer.
 */
public final class Persister<Value> {

    /// The payload that will be passed to an update listener.
    public typealias UpdatePayload = Result<Value?, Error>

    /// A closure that will be called when an update occurs.
    public typealias UpdateListener = (UpdatePayload) -> Void

    /// A closure that can retrieve a value.
    public typealias ValueGetter = () throws -> Value?

    /// A closure that can set a value.
    public typealias ValueSetter = (Value?) throws -> Void

    /// A closure that can add an update listener.
    public typealias AddUpdateListener = (@escaping UpdateListener) -> Cancellable

    #if canImport(Combine)
    /// A publisher that will publish updates as they occur.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var updatesPublisher: AnyPublisher<UpdatePayload, Never> {
        return updatesSubject.eraseToAnyPublisher()
    }
    #endif

    /// The closure that can be used to retrieve the value. This generally wraps the `Storage` and any
    /// `Transformer`s that are used to retrieve the value.
    private let valueGetter: ValueGetter

    /// The closure that can be used to store the value. This generally wraps the `Storage` and any
    /// `Transformer`s that are used to store the value.
    private let valueSetter: ValueSetter

    /// The cancellable that wraps the updates subscription added to the storage.
    private var storageUpdateListenerCancellable: Cancellable?

    /// A collection of the update listeners that will be notified when a value changes. The key (a `UUID`)
    /// is not exposed, but rather captured by the `Cancellable` that the caller retains.
    private var updateListeners: [UUID: UpdateListener] = [:]

    #if canImport(Combine)
    /// The upates subject used to publish updates.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private var updatesSubject: PassthroughSubject<UpdatePayload, Never> {
        return _updatesSubject as! PassthroughSubject<UpdatePayload, Never>
    }

    /// An `Any` value that will always be a `PassthroughSubject<UpdatePayload, Never>`.
    /// This is required because Swift does not support marking stored properties as `available`.
    private lazy var _updatesSubject: Any = {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            return PassthroughSubject<UpdatePayload, Never>()
        } else {
            preconditionFailure()
        }
    }()
    #endif

    /**
     Create a new `Persister` instance.

     - parameter valueGetter: The closure that will be called when the `retrieveValue()`
                              function is called.
     - parameter valueSetter: The closure that will be called when the `persist(_:)` function is
                              called.
     - parameter addUpdateListener: A closure that will be called immediately to add an update
                                    listener.
     */
    public init(
        valueGetter: @escaping ValueGetter,
        valueSetter: @escaping ValueSetter,
        addUpdateListener: AddUpdateListener
    ) {
        self.valueGetter = valueGetter
        self.valueSetter = valueSetter

        subscribeToStorageUpdates(addUpdateListener: addUpdateListener)
    }

    /**
     Create a new `Persister` instance that uses the provided `Storage` to retrieve and store values
     against the provided key.

     - parameter key: The key to retrieve and store values against.
     - parameter storage: The storage to use to retrieve and store vales.
     */
    public convenience init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage
    ) where Storage.Value == Value {
        let valueGetter: ValueGetter = {
            guard let value = try storage.retrieveValue(for: key) else { return nil }
            return value
        }

        let valueSetter: ValueSetter = { newValue in
            guard let newValue = newValue else {
                try storage.removeValue(for: key)
                return
            }

            try storage.storeValue(newValue, key: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            addUpdateListener: { updateListener in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let value = newValue else {
                        updateListener(.success(nil))
                        return
                    }

                    updateListener(.success(value))
                }
            }
        )
    }

    /**
     Create a new `Persister` instance that uses the provided `Storage` to retrieve and store values
     against the provided key.

     - parameter key: The key to retrieve and store values against.
     - parameter storage: The storage to use to retrieve and store vales.
     */
    public convenience init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage
    ) where Storage.Value == Any {
        let valueGetter: ValueGetter = {
            guard let anyValue = try storage.retrieveValue(for: key) else { return nil }
            guard let value = anyValue as? Value else {
                throw PersistenceError.unexpectedValueType(value: anyValue, expected: Value.self)
            }
            return value
        }

        let valueSetter: ValueSetter = { newValue in
            guard let newValue = newValue else {
                try storage.removeValue(for: key)
                return
            }

            try storage.storeValue(newValue, key: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            addUpdateListener: { updateListener in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let anyValue = newValue else {
                        updateListener(.success(nil))
                        return
                    }

                    guard let value = anyValue as? Value else {
                        updateListener(.failure(PersistenceError.unexpectedValueType(value: anyValue, expected: Value.self)))
                        return
                    }

                    updateListener(.success(value))
                }
            }
        )
    }

    /**
     Create a new `Persister` instance that uses the provided `Storage` to retrieve and store values
     against the provided key.  Values will be passed through the `Transformer` before being stored to
     and being retrieved from the storage.

     - parameter key: The key to retrieve and store values against.
     - parameter storage: The storage to use to retrieve and store vales.
     - parameter transformer: The transformer to use to transform the value when retrieving and
                              storing values.
     */
    public convenience init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer
    ) where Storage.Value == Any, Transformer.Input == Value {
        let valueGetter: ValueGetter = {
            guard let anyValue = try storage.retrieveValue(for: key) else { return nil }
            guard let transformerOutput = anyValue as? Transformer.Output else {
                throw PersistenceError.unexpectedValueType(value: anyValue, expected: Transformer.Output.self)
            }
            return try transformer.untransformValue(transformerOutput)
        }

        let valueSetter: ValueSetter = { newValue in
            guard let newValue = newValue else {
                try storage.removeValue(for: key)
                return
            }

            let transformedValue = try transformer.transformValue(newValue)
            try storage.storeValue(transformedValue, key: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            addUpdateListener: { updateListener in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let anyValue = newValue else {
                        updateListener(.success(nil))
                        return
                    }

                    guard let value = anyValue as? Transformer.Output else {
                        updateListener(.failure(PersistenceError.unexpectedValueType(value: anyValue, expected: Transformer.Output.self)))
                        return
                    }

                    do {
                        let untransformedValue = try transformer.untransformValue(value)
                        updateListener(.success(untransformedValue))
                    } catch {
                        updateListener(.failure(error))
                    }
                }
            }
        )
    }

    public convenience init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        let valueGetter: ValueGetter = {
            guard let value = try storage.retrieveValue(for: key) else { return nil }

            return try transformer.untransformValue(value)
        }

        let valueSetter: ValueSetter = { newValue in
            guard let newValue = newValue else {
                try storage.removeValue(for: key)
                return
            }

            let transformedValue = try transformer.transformValue(newValue)
            try storage.storeValue(transformedValue, key: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            addUpdateListener: { updateListener in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let newValue = newValue else {
                        updateListener(.success(nil))
                        return
                    }

                    do {
                        let untransformedValue = try transformer.untransformValue(newValue)
                        updateListener(.success(untransformedValue))
                    } catch {
                        updateListener(.failure(error))
                    }
                }
            }
        )
    }

    public func persist(_ newValue: Value?) throws {
        try valueSetter(newValue)
    }

    public func retrieveValue() throws -> Value? {
        return try valueGetter()
    }

    public func addUpdateListener(_ updateListener: @escaping UpdateListener) -> Cancellable {
        let uuid = UUID()
        updateListeners[uuid] = updateListener

        return Cancellable { [weak self] in
            self?.updateListeners.removeValue(forKey: uuid)
        }
    }

    private func notifyUpdateListenersOfResult(_ result: Result<Value?, Error>) {
        updateListeners.values.forEach { $0(result) }

        #if canImport(Combine)
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            updatesSubject.send(result)
        }
        #endif
    }

    private func subscribeToStorageUpdates(addUpdateListener: AddUpdateListener) {
        storageUpdateListenerCancellable = addUpdateListener { [weak self] result in
            guard let self = self else { return }

            self.notifyUpdateListenersOfResult(result)
        }
    }

}
