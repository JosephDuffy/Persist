#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

// MARK: - Value: StorableInUserDefaults

extension Persisted where Value: StorableInUserDefaults {

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: String,
        storedBy userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            userDefaults: userDefaults,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        wrappedValue: Value,
        key: String,
        storedBy userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            userDefaults: userDefaults,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: String,
        userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<Value>(),
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        wrappedValue: Value,
        key: String,
        userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<Value>(),
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}

extension Persisted {

    // MARK: - Value: StorableInUserDefaults?

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<WrappedValue>(
        key: String,
        storedBy userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<WrappedValue>(
        wrappedValue: Value,
        key: String,
        storedBy userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<WrappedValue>(
        key: String,
        userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<WrappedValue>(),
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`, storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<WrappedValue>(
        wrappedValue: Value,
        key: String,
        userDefaults: UserDefaults,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<WrappedValue>(),
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
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
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        wrappedValue: Value,
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
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
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        wrappedValue: Value,
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
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
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        wrappedValue: Value,
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
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
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values in the specified
     `UserDefaults`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in memory to improve performance when retrieving values, at the cost of increased memory usage.     
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        wrappedValue: Value,
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output: StorableInUserDefaults, Value == WrappedValue? {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
#endif
