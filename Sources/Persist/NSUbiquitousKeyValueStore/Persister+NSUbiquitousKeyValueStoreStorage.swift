#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

extension Persister where Value: StorableInNSUbiquitousKeyValueStore {

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
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        self.init(key: key, nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage, transformer: transformer)
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: nsUbiquitousKeyValueStoreStorage,
            transformer: aggregateTransformer
        )
    }

}
#endif
