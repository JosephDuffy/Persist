import Foundation

extension Persister where Value: StorableInUbiquitousKeyValueStore {

    public convenience init(
        key: String,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage
    ) {
        self.init(
            key: key,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage
        )
    }

    public convenience init(
        key: String,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage
    ) {
        self.init(
            key: key,
            storedBy: nsUbiquitousKeyValueStoreStorage,
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Value>()
        )
    }

}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        self.init(key: key, nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage, transformer: transformer)
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: nsUbiquitousKeyValueStoreStorage,
            transformer: aggregateTransformer
        )
    }

}
