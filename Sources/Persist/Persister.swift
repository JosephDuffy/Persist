import Foundation
#if canImport(Combine)
import Combine
#endif

extension Persister.Update.Event: Hashable where Value: Hashable {}
extension Persister.Update.Event: Equatable where Value: Equatable {}
extension Persister.Update: Hashable where Value: Hashable {}
extension Persister.Update: Equatable where Value: Equatable {}

/**
 An object that can store and retrieve values from a `Storage` instance, optionally passing values through a
 transformer.
 */
public final class Persister<Value> {
    /// An update that was performed by a persister.
    public struct Update {
        /// Create and return a new `Update` for a persisted value.
        ///
        /// - Parameter persistedValue: The value that was persisted.
        /// - Returns: The created `Update`.
        public static func persisted(_ persistedValue: Value) -> Update {
            return Update(newValue: persistedValue, event: .persisted(persistedValue))
        }

        /// Create and return a new `Update` for a removed value.
        ///
        /// - Parameter defaultValue: The default value that will be falled back to.
        /// - Returns: The created `Update`.
        public static func removed(defaultValue: Value) -> Update {
            return Update(newValue: defaultValue, event: .removed)
        }

        /// An event that triggers an update.
        public enum Event {
            /// The was persisted.
            case persisted(Value)

            /// The value was removed.
            case removed

            /// The value after the update. `nil` indicates the value was removed.
            public var value: Value? {
                switch self {
                case .persisted(let value):
                    return value
                case .removed:
                    return nil
                }
            }
        }

        /// The new value, after the update. If the value was removed this will be the default value.
        public let newValue: Value

        /// The event that triggered the update.
        public let event: Event

        private init(newValue: Value, event: Event) {
            self.newValue = newValue
            self.event = event
        }
    }

    /// The payload that will be passed to an update listener.
    public typealias UpdatePayload = Result<Update, Error>

    /// A closure that will be called when an update occurs.
    public typealias UpdateListener = (UpdatePayload) -> Void

    /// A closure that can retrieve a value.
    public typealias ValueGetter = () throws -> Value?

    /// A closure that can set a value.
    public typealias ValueSetter = (Value) throws -> Void

    /// A closure that can remove a value.
    public typealias ValueRemover = () throws -> Void

    /// A closure that can add an update listener.
    public typealias AddUpdateListener = (_ updateListener: @escaping UpdateListener, _ defaultValueGetter: @escaping () -> Value) -> AnyCancellable

    #if canImport(Combine)
    /// A publisher that will publish updates as they occur.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var updatesPublisher: AnyPublisher<UpdatePayload, Never> {
        return updatesSubject.eraseToAnyPublisher()
    }
    #endif

    /// The default value that will be returned when a value has been be persisted or an error occurs.
    public lazy var defaultValue: Value = {
        return _defaultValue()
    }()

    private var defaultValueLock = NSLock()

    /// An option set that describes when to persist the default value.
    public var defaultValuePersistBehaviour: DefaultValuePersistOption

    private let _defaultValue: () -> Value

    /// The closure that can be used to retrieve the value. This generally wraps the `Storage` and any
    /// `Transformer`s that are used to retrieve the value.
    private let valueGetter: ValueGetter

    /// The closure that can be used to store the value. This generally wraps the `Storage` and any
    /// `Transformer`s that are used to store the value.
    private let valueSetter: ValueSetter

    /// The closure that can be used to store the value. This generally wraps the `Storage`.
    private let valueRemover: ValueRemover

    /// The cancellable object that encapsulates updates from the storage.
    private var storageUpdateListenerCancellable: AnyCancellable?

    /// A collection of the update listeners that will be notified when a value changes. The key (a `UUID`)
    /// is not exposed, but rather captured by the `Subscription` that the caller retains.
    private var updateListeners: [UUID: UpdateListener] = [:]

    /// A lock used to protect access to ``updateListeners``.
    private let updateListenersLock = NSLock()

    #if canImport(Combine)
    /// The updates subject that publishes updates.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private var updatesSubject: PassthroughSubject<UpdatePayload, Never> {
        getUpdatesSubject()
    }

    /// An `Any` value that will always be a `PassthroughSubject<UpdatePayload, Never>`.
    /// This is required because Swift does not support marking stored properties as `available`.
    private var _updatesSubject: Any?

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private func getUpdatesSubject() -> PassthroughSubject<UpdatePayload, Never> {
        if let updatesSubject = _updatesSubject as? PassthroughSubject<UpdatePayload, Never> {
            return updatesSubject
        }

        let updatesSubject = PassthroughSubject<UpdatePayload, Never>()
        _updatesSubject = updatesSubject
        return updatesSubject
    }
    #endif

    /**
     Create a new `Persister` instance.

     - parameter valueGetter: The closure that will be called when the `retrieveValue()` function is called.
     - parameter valueSetter: The closure that will be called when the `persist(_:)` function is called.
     - parameter valueRemover: The closure that will be called when the `removeValue()` function is called.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. This value is lazily evaluated.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     - parameter addUpdateListener: A closure that will be called immediately to add an update listener.
     */
    public init(
        valueGetter: @escaping ValueGetter,
        valueSetter: @escaping ValueSetter,
        valueRemover: @escaping ValueRemover,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = [],
        addUpdateListener: AddUpdateListener
    ) {
        self.valueGetter = valueGetter
        self.valueSetter = valueSetter
        self.valueRemover = valueRemover
        _defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        subscribeToStorageUpdates(addUpdateListener: addUpdateListener)
    }

    // MARK: - Storage.Value == Value

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Value {
        let valueGetter: ValueGetter = {
            guard let value = try storage.retrieveValue(for: key) else { return nil }
            return value
        }

        let valueSetter: ValueSetter = { newValue in
            try storage.storeValue(newValue, key: key)
        }

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let value = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    updateListener(.success(.persisted(value)))
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
    public convenience init<Storage: Persist.Storage, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == WrappedValue, Value == Optional<WrappedValue> {
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

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let value = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    updateListener(.success(.persisted(value)))
                }
            }
        )
    }

    // MARK: - Storage.Value == Any

    /**
     Create a new `Persister` instance that uses the provided `Storage` to retrieve and store values
     against the provided key.

     - parameter key: The key to retrieve and store values against.
     - parameter storage: The storage to use to retrieve and store vales.
     */
    public convenience init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any {
        let valueGetter: ValueGetter = {
            guard let anyValue = try storage.retrieveValue(for: key) else { return nil }
            guard let value = anyValue as? Value else {
                throw PersistenceError.unexpectedValueType(value: anyValue, expected: Value.self)
            }
            return value
        }

        let valueSetter: ValueSetter = { newValue in
            try storage.storeValue(newValue, key: key)
        }

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let anyValue = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    guard let value = anyValue as? Value else {
                        updateListener(.failure(PersistenceError.unexpectedValueType(value: anyValue, expected: Value.self)))
                        return
                    }

                    updateListener(.success(.persisted(value)))
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
    public convenience init<Storage: Persist.Storage, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Value == Optional<WrappedValue> {
        let valueGetter: ValueGetter = {
            guard let anyValue = try storage.retrieveValue(for: key) else { return nil }
            guard let value = anyValue as? WrappedValue else {
                throw PersistenceError.unexpectedValueType(value: anyValue, expected: WrappedValue.self)
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

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let anyValue = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    guard let value = anyValue as? WrappedValue else {
                        updateListener(.failure(PersistenceError.unexpectedValueType(value: anyValue, expected: WrappedValue.self)))
                        return
                    }

                    updateListener(.success(.persisted(value)))
                }
            }
        )
    }

    // MARK: - Storage.Value == Any, Transformer.Input == Value

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
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == Value {
        let valueGetter: ValueGetter = {
            guard let anyValue = try storage.retrieveValue(for: key) else { return nil }
            guard let transformerOutput = anyValue as? Transformer.Output else {
                throw PersistenceError.unexpectedValueType(value: anyValue, expected: Transformer.Output.self)
            }
            return try transformer.untransformValue(transformerOutput)
        }

        let valueSetter: ValueSetter = { newValue in
            let transformedValue = try transformer.transformValue(newValue)
            try storage.storeValue(transformedValue, key: key)
        }

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let anyValue = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    guard let value = anyValue as? Transformer.Output else {
                        updateListener(.failure(PersistenceError.unexpectedValueType(value: anyValue, expected: Transformer.Output.self)))
                        return
                    }

                    do {
                        let untransformedValue = try transformer.untransformValue(value)
                        updateListener(.success(.persisted(untransformedValue)))
                    } catch {
                        updateListener(.failure(error))
                    }
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
    public convenience init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == WrappedValue, Value == WrappedValue? {
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

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let anyValue = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    guard let value = anyValue as? Transformer.Output else {
                        updateListener(.failure(PersistenceError.unexpectedValueType(value: anyValue, expected: Transformer.Output.self)))
                        return
                    }

                    do {
                        let untransformedValue = try transformer.untransformValue(value)
                        updateListener(.success(.persisted(untransformedValue)))
                    } catch {
                        updateListener(.failure(error))
                    }
                }
            }
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output == Storage.Value

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        let valueGetter: ValueGetter = {
            guard let value = try storage.retrieveValue(for: key) else { return nil }

            return try transformer.untransformValue(value)
        }

        let valueSetter: ValueSetter = { newValue in
            let transformedValue = try transformer.transformValue(newValue)
            try storage.storeValue(transformedValue, key: key)
        }

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let newValue = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    do {
                        let untransformedValue = try transformer.untransformValue(newValue)
                        updateListener(.success(.persisted(untransformedValue)))
                    } catch {
                        updateListener(.failure(error))
                    }
                }
            }
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output == Storage.Value, Value == WrappedValue? {
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

        let valueRemover: ValueRemover = {
            try storage.removeValue(for: key)
        }

        self.init(
            valueGetter: valueGetter,
            valueSetter: valueSetter,
            valueRemover: valueRemover,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour,
            addUpdateListener: { updateListener, defaultValueGetter in
                return storage.addUpdateListener(forKey: key) { newValue in
                    guard let newValue = newValue else {
                        updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                        return
                    }

                    do {
                        let untransformedValue = try transformer.untransformValue(newValue)
                        updateListener(.success(.persisted(untransformedValue)))
                    } catch {
                        updateListener(.failure(error))
                    }
                }
            }
        )
    }

    // MARK: - Functions

    /**
     Persist the provided value.

     - throws: Any errors thrown by the storage.
     */
    public func persist(_ newValue: Value) throws {
        try valueSetter(newValue)
    }

    /**
     Attempts to retrieve the value from the storage. If the value is `nil` or an error occurs when retrieving
     the value the default value will be returned.

     If the `persistWhenNil` option has been provided and the storage returns `nil` the default value
     will be persisted.

     If the `persistOnError` option has been provided and there is an error retrieving the value the default
     value will be persisted.

     - returns: The persisted value, or the default value if no value has been persisted or an error occurs.
     */
    public func retrieveValue() -> Value {
        do {
            return try retrieveValueOrThrow()
        } catch {
            defaultValueLock.lock()
            let defaultValue = self.defaultValue
            if defaultValuePersistBehaviour.contains(.persistOnError) {
                try? persist(defaultValue)
            }
            defaultValueLock.unlock()

            return defaultValue
        }
    }

    /**
     Attempts to retrieve the value from the storage. If the value is `nil` the default value will be returned.

     If the `persistWhenNil` option has been provided and the storage returns `nil` the default value
     will be persisted.

     If the `persistOnError` option has been provided and there is an error retrieving the value the default
    value will **not** be persisted and the error will be thrown.

     - throws: Any error thrown while retrieving the value.
     - returns: The persisted value, or the default value if no value has been persisted.
     */
    public func retrieveValueOrThrow() throws -> Value {
        if let retrieveValue = try valueGetter() {
            return retrieveValue
        }

        defaultValueLock.lock()
        let defaultValue = self.defaultValue
        if defaultValuePersistBehaviour.contains(.persistWhenNil) {
            try? persist(defaultValue)
        }
        defaultValueLock.unlock()

        return defaultValue
    }

    /**
     Remove the value.

     - throws: Any errors thrown by the storage.
     */
    public func removeValue() throws {
        return try valueRemover()
    }

    /**
     Add a closure that will be called when the storage notifies the persister of an update.

     - parameter updateListener: The closure to call when an update occurs.
     - returns: An object that represents the closure's subscription to changes. This object must be retained by the caller.
     */
    public func addUpdateListener(_ updateListener: @escaping UpdateListener) -> AnyCancellable {
        let uuid = UUID()
        updateListenersLock.lock()
        updateListeners[uuid] = updateListener
        updateListenersLock.unlock()

        return Subscription { [weak self] in
            guard let self = self else { return }
            self.updateListenersLock.lock()
            self.updateListeners.removeValue(forKey: uuid)
            self.updateListenersLock.unlock()
        }.eraseToAnyCancellable()
    }

    private func notifyUpdateListenersOfResult(_ result: UpdatePayload) {
        updateListenersLock.lock()
        updateListeners.values.forEach { $0(result) }
        updateListenersLock.unlock()

        #if canImport(Combine)
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            updatesSubject.send(result)
        }
        #endif
    }

    private func subscribeToStorageUpdates(addUpdateListener: AddUpdateListener) {
        storageUpdateListenerCancellable = addUpdateListener(
            { [weak self] result in
                self?.notifyUpdateListenersOfResult(result)
            },
            { [unowned self] in
                self.defaultValueLock.lock()
                let defaultValue = self.defaultValue
                self.defaultValueLock.unlock()
                return defaultValue
            }
        )
    }

}
