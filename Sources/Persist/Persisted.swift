import Foundation

/**
 A property wrapper that wraps a `Persister`.
 */
@propertyWrapper
public struct Persisted<Value> {

    /// The value that is persisted by the `Persister`.
    public var wrappedValue: Value {
        get {
            return projectedValue.retrieveValue()
        }
        nonmutating set {
            try? projectedValue.persist(newValue)
        }
    }

    /// The `Persister` used to persist and retrieve the value.
    public private(set) var projectedValue: Persister<Value>

    /**
     Create a new instance that uses the provided `Persister` to persist and retrieve the value.
     */
    public init(persister: Persister<Value>) {
        projectedValue = persister
    }

    // MARK: - Storage.Value == Value

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == WrappedValue, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, WrappedValue>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == WrappedValue, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Storage.Value == Any

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error
        occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, WrappedValue>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Storage.Value == Any, Transformer.Input == Value

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == WrappedValue, Value == WrappedValue? {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `wrappedValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against.
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage.
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == WrappedValue, Value == WrappedValue? {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output == Storage.Value

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `wrappedValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output == Storage.Value, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `wrappedValue`. Values stored will be processed by the provided transformer before being persisted
     and after being retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter cacheValue: When `true` the latest value will be cached in
       memory to improve performance when retrieving values, at the cost of
       increased memory usage.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        cacheValue: Bool = false,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output == Storage.Value, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            cacheValue: cacheValue,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
