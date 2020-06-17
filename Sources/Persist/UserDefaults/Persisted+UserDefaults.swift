#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

// MARK: - Value: StorableInUserDefaults

extension Persisted where Value: StorableInUserDefaults {

    public init(
        key: String,
        storedBy userDefaults: UserDefaults,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            userDefaults: userDefaults,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init(
        key: String,
        userDefaults: UserDefaults,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<Value>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}

extension Persisted {

    // MARK: - Value: StorableInUserDefaults?

    public init<WrappedValue>(
        key: String,
        storedBy userDefaults: UserDefaults,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<WrappedValue>(
        key: String,
        userDefaults: UserDefaults,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<WrappedValue>(),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output: StorableInUserDefaults

    public init<Transformer: Persist.Transformer>(
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults
    
    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
#endif
