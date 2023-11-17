import Foundation

/**
 A property wrapper that wraps a `Persister`.
 */
@propertyWrapper
public struct Persisted<Value, Storage: Persist.Storage> where Storage.Value == Value {
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
    public private(set) var projectedValue: Persister<Value, Storage>

    /**
     Create a new instance that uses the provided `Persister` to persist and retrieve the value.
     */
    public init(persister: Persister<Value, Storage>) {
        projectedValue = persister
    }

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        wrappedValue: Value,
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValuePersistBehaviour: DefaultValuePersistOption = [],
        valueType: Value.Type = Value.self
    ) {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
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
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<WrappedStorage: Persist.Storage>(
        wrappedValue: Value,
        key: WrappedStorage.Key,
        storedBy storage: WrappedStorage,
        transformer: any Transformer<Value, WrappedStorage.Value>,
        defaultValuePersistBehaviour: DefaultValuePersistOption = [],
        valueType: Value.Type = Value.self
    ) where WrappedStorage.Key == Storage.Key, Storage == TransformedStorage<WrappedStorage.Key, Value> {
        projectedValue = Persister<Value, Storage>(
            key: key,
            storedBy: storage,
            transformer: transformer,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<WrappedValue, WrappedStorage: Persist.Storage>(
        wrappedValue: WrappedValue? = nil,
        key: WrappedStorage.Key,
        storedBy storage: WrappedStorage,
        transformer: any Transformer<Value, WrappedStorage.Value>,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, WrappedStorage.Key == Storage.Key, Storage == TransformedStorage<WrappedStorage.Key, Value> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            defaultValue: wrappedValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }
}
