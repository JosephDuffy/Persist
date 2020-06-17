#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

// MARK: - Value: StorableInNSUbiquitousKeyValueStore

extension Persister where Value: StorableInNSUbiquitousKeyValueStore {

    public convenience init(
        key: String,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init(
        key: String,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: nsUbiquitousKeyValueStoreStorage,
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Value>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}

extension Persister {

    // MARK: - Value: StorableInNSUbiquitousKeyValueStore?

    public convenience init<WrappedValue>(
        key: String,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<WrappedValue>(
        key: String,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: nsUbiquitousKeyValueStoreStorage,
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<WrappedValue>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        self.init(
            key: key,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: nsUbiquitousKeyValueStoreStorage,
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        storedBy nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: nsUbiquitousKeyValueStoreStorage,
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
#endif
