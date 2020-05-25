#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

public protocol StorableInUbiquitousKeyValueStore {
    var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue { get }
}

public typealias StoredInUbiquitousKeyValueStore<Value: StorableInUbiquitousKeyValueStore> = Persisted<Value>

extension Persisted where Value: StorableInUbiquitousKeyValueStore {

    public init(
        key: String,
        defaultValue: Value? = nil,
        storedBy storage: UbiquitousKeyValueStore
    ) {
        let persister = Persister<Value>(key: key, storedBy: storage)
        self.init(persister: persister, defaultValue: defaultValue)
    }

    public init(
        key: String,
        defaultValue: Value? = nil,
        ubiquitousKeyValueStore: UbiquitousKeyValueStore
    ) {
        let persister = Persister<Value>(key: key, storedBy: ubiquitousKeyValueStore)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        storedBy storage: UbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        let persister = Persister(key: key, storedBy: storage, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        ubiquitousKeyValueStore: UbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        let persister = Persister(key: key, storedBy: ubiquitousKeyValueStore, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persister where Value: StorableInUbiquitousKeyValueStore {

    public convenience init(
        key: String,
        storedBy storage: UbiquitousKeyValueStore
    ) {
        self.init(
            key: key,
            storedBy: storage,
            transformer: StorableInUbiquitousKeyValueStoreTransformer<Value>()
        )
    }

    public convenience init(
        key: String,
        ubiquitousKeyValueStore: UbiquitousKeyValueStore
    ) {
        self.init(
            key: key,
            storedBy: ubiquitousKeyValueStore,
            transformer: StorableInUbiquitousKeyValueStoreTransformer<Value>()
        )
    }

}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy storage: UbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        let aggregateTransformer = transformer.append(transformer: StorableInUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(key: key, storedBy: storage, transformer: aggregateTransformer)
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        ubiquitousKeyValueStore: UbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        let aggregateTransformer = transformer.append(transformer: StorableInUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(key: key, storedBy: ubiquitousKeyValueStore, transformer: aggregateTransformer)
    }

}

extension String: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue {
        return .string(self)
    }
}

extension Data: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue {
        return .data(self)
    }
}

extension Bool: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue {
        return .bool(self)
    }
}

extension Int64: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue {
        return .int64(self)
    }
}

extension Double: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue {
        return .double(self)
    }
}

extension Array: StorableInUbiquitousKeyValueStore where Element: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue {
        return .array(map(\.asUbiquitousKeyValueStoreValue))
    }
}

extension Dictionary: StorableInUbiquitousKeyValueStore where Key == String, Value: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: UbiquitousKeyValueStoreValue {
        return .dictionary(mapValues(\.asUbiquitousKeyValueStoreValue))
    }
}
#endif
