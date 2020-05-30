import Foundation
#if canImport(Combine)
import Combine
#endif

public final class Persister<Value> {

    public typealias UpdatePayload = Result<Value?, Error>

    public typealias UpdateListener = (UpdatePayload) -> Void

    public typealias ValueGetter = () throws -> Value?

    public typealias ValueSetter = (Value?) throws -> Void

    public typealias AddUpdateListener = (@escaping (UpdatePayload) -> Void) -> Cancellable

    #if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var updatesPublisher: AnyPublisher<UpdatePayload, Never> {
        return updatesSubject.eraseToAnyPublisher()
    }
    #endif

    private let valueGetter: ValueGetter

    private let valueSetter: ValueSetter

    private var storageUpdateListenerCancellable: Cancellable?

    private var updateListeners: [UUID: UpdateListener] = [:]

    #if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private var updatesSubject: PassthroughSubject<UpdatePayload, Never> {
        return _updatesSubject as! PassthroughSubject<UpdatePayload, Never>
    }

    private lazy var _updatesSubject: Any = {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            return PassthroughSubject<UpdatePayload, Never>()
        } else {
            preconditionFailure()
        }
    }()
    #endif

    public init(
        valueGetter: @escaping ValueGetter,
        valueSetter: @escaping ValueSetter,
        addUpdateListener: AddUpdateListener
    ) {
        self.valueGetter = valueGetter
        self.valueSetter = valueSetter

        subscribeToStorageUpdates(addUpdateListener: addUpdateListener)
    }

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
