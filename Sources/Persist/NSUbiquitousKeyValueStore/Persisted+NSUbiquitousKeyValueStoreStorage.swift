import Foundation

extension StoredInNSUbiquitousKeyValueStore {

    public init(
        key: String,
        defaultValue: Value? = nil,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage
    ) {
        self.init(
            key: key,
            defaultValue: defaultValue,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage
        )
    }

    public init(
        key: String,
        defaultValue: Value? = nil,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage
    ) {
        let persister = Persister<Value>(key: key, nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        self.init(
            key: key,
            defaultValue: defaultValue,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage,
            transformer: transformer
        )
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUbiquitousKeyValueStore {
        let persister = Persister(
            key: key,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage,
            transformer: transformer
        )
        self.init(persister: persister, defaultValue: defaultValue)
    }

}
