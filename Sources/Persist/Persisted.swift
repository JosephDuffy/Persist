import Foundation

@propertyWrapper
public struct Persisted<Value> {

    public var wrappedValue: Value? {
        mutating get {
            if let retrieveValue = try? projectedValue.retrieveValue(){
                return retrieveValue
            } else if let defaultValue = defaultValue {
                if persistDefaultValue {
                    try? projectedValue.persist(defaultValue)
                }

                return defaultValue
            }

            return nil
        }
        set {
            try? projectedValue.persist(newValue)
        }
    }

    public private(set) var projectedValue: Persister<Value>

    public var defaultValue: Value?

    /// If `true` the default value will be persisted using the `Persister` whenever it is used as the
    /// value returned by `wrappedValue`.
    public var persistDefaultValue: Bool

    public init(
        persister: Persister<Value>,
        defaultValue: Value? = nil,
        persistDefaultValue: Bool = true
    ) {
        self.defaultValue = defaultValue
        self.persistDefaultValue = persistDefaultValue

        projectedValue = persister
    }

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        persistDefaultValue: Bool = true
    ) where Storage.Value == Value {
        self.defaultValue = defaultValue
        self.persistDefaultValue = persistDefaultValue

        projectedValue = Persister(key: key, storedBy: storage)
    }

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        persistDefaultValue: Bool = true
    ) where Storage.Value == Any {
        self.defaultValue = defaultValue
        self.persistDefaultValue = persistDefaultValue

        projectedValue = Persister(key: key, storedBy: storage)
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        transformer: Transformer,
        persistDefaultValue: Bool = true
    ) where Storage.Value == Any, Transformer.Input == Value {
        self.defaultValue = defaultValue
        self.persistDefaultValue = persistDefaultValue

        projectedValue = Persister(key: key, storedBy: storage, transformer: transformer)
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        transformer: Transformer,
        persistDefaultValue: Bool = true
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        self.defaultValue = defaultValue
        self.persistDefaultValue = persistDefaultValue

        projectedValue = Persister(key: key, storedBy: storage, transformer: transformer)
    }

}
