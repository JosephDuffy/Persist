import Foundation
import Combine

public final class Persister<Value> {

    public typealias UpdatePayload = Result<Value?, Error>

    public typealias UpdateListener = (UpdatePayload) -> Void

    public let key: String

    public private(set) var storage: Storage

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var updatesPublisher: AnyPublisher<UpdatePayload, Never> {
        return updatesSubject.eraseToAnyPublisher()
    }

    private let transform: AnyOutputTransform<Value>?

    private let untransform: AnyOutputUntransform<Value>?

    private var storageUpdateListenerCancellable: Cancellable?

    private var updateListeners: [UUID: UpdateListener] = [:]

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

    public init<Transformer: Persist.Transformer>(key: String, storedBy storage: Storage, transformer: Transformer) where Transformer.Input == Value {
        self.key = key
        self.storage = storage
        transform = transformer.anyOutputTransform()
        untransform = transformer.anyOutputUntransform()

        subscribeToStorageUpdatesIfPossible()
    }

    public init(key: String, storedBy storage: Storage) {
        self.key = key
        self.storage = storage
        transform = nil
        untransform = nil

        subscribeToStorageUpdatesIfPossible()
    }

    public func persist(_ value: Value) throws {
        if let transform = transform {
            let transformedValue = try transform(value)
            try storage.storeValue(transformedValue, key: key)
        } else {
            try storage.storeValue(value, key: key)
        }

        if !(storage is UpdatePropagatingStorage) {
            notifyUpdateListenersOfResult(.success(value))
        }
    }

    public func removeValue() throws {
        try storage.removeValue(for: key)

        if !(storage is UpdatePropagatingStorage) {
            notifyUpdateListenersOfResult(.success(nil))
        }
    }

    public func retrieveValue() throws -> Value? {
        if let untransform = untransform {
            guard let storedValue: Any = try storage.retrieveValue(for: key) else { return nil }
            return try untransform(storedValue)
        } else {
            let result: Value? = try storage.retrieveValue(for: key)
            return result
        }
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

        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            updatesSubject.send(result)
        }
    }

    private func subscribeToStorageUpdatesIfPossible() {
        guard let updatePropagatingStorage = storage as? UpdatePropagatingStorage else { return }

        storageUpdateListenerCancellable = updatePropagatingStorage.addUpdateListener(forKey: key) { [weak self] value in
            guard let self = self else { return }

            let result: Result<Value?, Error>

            defer {
                self.notifyUpdateListenersOfResult(result)
            }

            if let value = value {
                if let value = value as? Value {
                    result = .success(value)
                } else {
                    result = .failure(PersistanceError.unexpectedValueType(value: value, expected: Value.self))
                }
            } else {
                result = .success(nil)
            }
        }
    }

}

private typealias AnyOutputTransform<Input> = (_ value: Input) throws -> Any
private typealias AnyOutputUntransform<Input> = (_ output: Any) throws -> Input

extension Transformer {

    fileprivate func anyOutputTransform() -> AnyOutputTransform<Input> {
        return { value in
            return try self.transformValue(value)
        }
    }

    fileprivate func anyOutputUntransform() -> AnyOutputUntransform<Input> {
        return { anyOutput in
            guard let output = anyOutput as? Output else {
                throw PersistanceError.unexpectedValueType(value: anyOutput, expected: Output.self)
            }
            return try self.untransformValue(from: output)
        }
    }

}
