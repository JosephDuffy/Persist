#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

// MARK: - Value: StorableInUserDefaults

extension Persister where Value: StorableInUserDefaults {

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init(
        key: String,
        storedBy userDefaults: UserDefaults,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            userDefaults: userDefaults,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init(
        key: String,
        userDefaults: UserDefaults,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<Value>(),
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}

extension Persister {

    // MARK: - Value: StorableInUserDefaults?

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<WrappedValue>(
        key: String,
        storedBy userDefaults: UserDefaults,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<WrappedValue>(
        key: String,
        userDefaults: UserDefaults,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<WrappedValue>(),
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output: StorableInUserDefaults

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
#endif
