import Foundation

extension Persister where Value: StorableInUbiquitousKeyValueStore {

    public convenience init(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore
    ) {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore
        )
    }

    public convenience init(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore
    ) {
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Value>()
        )
    }

}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        self.init(key: key, nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore, transformer: transformer)
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        let storage = NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore)
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: storage,
            transformer: aggregateTransformer
        )
    }

}
