#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

// MARK: - Value: StorableInNSUbiquitousKeyValueStore

extension Persisted where Value: StorableInNSUbiquitousKeyValueStore {

    public init(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Value>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}

extension Persisted {

    // MARK: - Value: StorableInNSUbiquitousKeyValueStore?

    public init<WrappedValue>(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<WrappedValue>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: StorableInNSUbiquitousKeyValueStoreTransformer<WrappedValue>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    public init<Transformer: Persist.Transformer>(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        storedBy nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        self.init(
            key: key,
            nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInNSUbiquitousKeyValueStoreTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: nsUbiquitousKeyValueStore),
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
#endif
