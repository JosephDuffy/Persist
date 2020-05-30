#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

extension Persister where Value: StorableInNSUbiquitousKeyValueStore {

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
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        self.init(key: key, nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore, transformer: transformer)
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        let storage = NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore)
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: storage,
            transformer: aggregateTransformer
        )
    }

}
#endif
