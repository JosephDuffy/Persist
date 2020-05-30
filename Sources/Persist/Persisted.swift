import Foundation

@propertyWrapper
public struct Persisted<Value> {

    public var wrappedValue: Value? {
        mutating get {
            do {
                if let retrieveValue = try projectedValue.retrieveValue() {
                    return retrieveValue
                } else if let defaultValue = defaultValue {
                    if defaultValuePersistBehaviour.contains(.persistWhenNil) {
                        try? projectedValue.persist(defaultValue)
                    }

                    return defaultValue
                }

                return nil
            } catch {
                if defaultValuePersistBehaviour.contains(.persistOnError) {
                    try? projectedValue.persist(defaultValue)
                }

                return defaultValue
            }
        }
        set {
            try? projectedValue.persist(newValue)
        }
    }

    public private(set) var projectedValue: Persister<Value>

    public var defaultValue: Value?

    public var defaultValuePersistBehaviour: DefaultValuePersistOption

    public init(
        persister: Persister<Value>,
        defaultValue: Value? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        projectedValue = persister
    }

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Value {
        self.defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        projectedValue = Persister(key: key, storedBy: storage)
    }

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any {
        self.defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        projectedValue = Persister(key: key, storedBy: storage)
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Storage.Value == Any, Transformer.Input == Value {
        self.defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        projectedValue = Persister(key: key, storedBy: storage, transformer: transformer)
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        transformer: Transformer,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        self.defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        projectedValue = Persister(key: key, storedBy: storage, transformer: transformer)
    }

}
