#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

extension StoredInNSUbiquitousKeyValueStore {

    public init(
        key: String,
        defaultValue: Value? = nil,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore
    ) {
        self.init(
            key: key,
            defaultValue: defaultValue,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore
        )
    }

    public init(
        key: String,
        defaultValue: Value? = nil,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore
    ) {
        let persister = Persister<Value>(key: key, nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        self.init(
            key: key,
            defaultValue: defaultValue,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            transformer: transformer
        )
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        let persister = Persister(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            transformer: transformer
        )
        self.init(persister: persister, defaultValue: defaultValue)
    }

}
#endif
