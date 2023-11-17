public final class TransformedStorage<Key, Value>: Persist.Storage {
    private let pair: any StorageTransformerPairProtocol<Key, Value>

    public init<Storage: Persist.Storage>(
        transformer: some Transformer<Value, Storage.Value>,
        storage: Storage
    ) where Storage.Key == Key {
        pair = StorageTransformerPair(transformer: transformer, storage: storage)
    }

    public func storeValue(_ value: Value, key: Key) throws {
        try pair.storeValue(value, key: key)
    }

    public func retrieveValue(for key: Key) throws -> Value? {
        try pair.retrieveValue(for: key)
    }

    public func removeValue(for key: Key) throws {
        try pair.removeValue(for: key)
    }

    public func addUpdateListener(forKey key: Key, updateListener: @escaping (Value?) -> Void) -> AnyCancellable {
        pair.addUpdateListener(forKey: key, updateListener: updateListener)
    }
}

private protocol StorageTransformerPairProtocol<Key, Value>: Storage {
    associatedtype Key
    associatedtype Value
    associatedtype StoredValue

    var transformer: any Transformer<Value, StoredValue> { get }

    var storage: any Storage<Key, StoredValue> { get }
}

private final class StorageTransformerPair<Key, Value, StoredValue>: StorageTransformerPairProtocol {
    fileprivate let transformer: any Transformer<Value, StoredValue>

    fileprivate let storage: any Storage<Key, StoredValue>

    fileprivate init(transformer: some Transformer<Value, StoredValue>, storage: some Storage<Key, StoredValue>) {
        self.transformer = transformer
        self.storage = storage
    }

    fileprivate func storeValue(_ value: Value, key: Key) throws {
        let transformedValue = try transformer.transformValue(value)
        try storage.storeValue(transformedValue, key: key)
    }

    fileprivate func retrieveValue(for key: Key) throws -> Value? {
        if let storedValue = try storage.retrieveValue(for: key) {
            return try transformer.untransformValue(storedValue)
        } else {
            return nil
        }
    }

    fileprivate func removeValue(for key: Key) throws {
        try storage.removeValue(for: key)
    }

    fileprivate func addUpdateListener(forKey key: Key, updateListener: @escaping UpdateListener) -> AnyCancellable {
        storage.addUpdateListener(forKey: key) { [transformer] storedValue in
            if let storedValue {
                do {
                    let transformedValue = try transformer.untransformValue(storedValue)
                    updateListener(transformedValue)
                } catch {}
            } else {
                updateListener(nil)
            }
        }
    }
}
