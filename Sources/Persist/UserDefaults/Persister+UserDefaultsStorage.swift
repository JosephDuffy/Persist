#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

// MARK: - Value: StorableInUserDefaults

extension Persister where Value: StorableInUserDefaults {

    public convenience init(
        key: String,
        storedBy userDefaultsStorage: UserDefaultsStorage,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            userDefaultsStorage: userDefaultsStorage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init(
        key: String,
        userDefaultsStorage: UserDefaultsStorage,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: userDefaultsStorage,
            transformer: StorableInUserDefaultsTransformer<Value>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}

extension Persister {

    // MARK: - Value: StorableInNSUbiquitousKeyValueStore?

    public convenience init<WrappedValue>(
        key: String,
        storedBy userDefaultsStorage: UserDefaultsStorage,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaultsStorage: userDefaultsStorage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<WrappedValue>(
        key: String,
        userDefaultsStorage: UserDefaultsStorage,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: userDefaultsStorage,
            transformer: StorableInUserDefaultsTransformer<WrappedValue>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(
            key: key,
            userDefaultsStorage: userDefaultsStorage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: userDefaultsStorage,
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == WrappedValue, Transformer.Output: StorableInNSUbiquitousKeyValueStore

    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        storedBy userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaultsStorage: userDefaultsStorage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: userDefaultsStorage,
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
#endif
