import Foundation

@propertyWrapper
public struct Persisted<Value> {

    public var wrappedValue: Value {
        get {
            return projectedValue.retrieveValue()
        }
        set {
            try? projectedValue.persist(newValue)
        }
    }

    public private(set) var projectedValue: Persister<Value>

    public init(persister: Persister<Value>) {
        projectedValue = persister
    }

    // MARK: - Storage.Value == Value

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Storage: Persist.Storage, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == WrappedValue, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Storage.Value == Any

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Storage: Persist.Storage, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Storage.Value == Any, Transformer.Input == Value

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == WrappedValue, Value == WrappedValue? {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Transformer.Input == Value, Transformer.Output == Storage.Value

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer, WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == WrappedValue, Transformer.Output == Storage.Value, Value == Optional<WrappedValue> {
        projectedValue = Persister(
            key: key,
            storedBy: storage,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
