import Foundation

@propertyWrapper
public struct Persisted<Value> {

    public var wrappedValue: Value? {
        mutating get {
            return try? projectedValue.retrieveValue() ?? defaultValue
        }
        set {
            try? projectedValue.persist(newValue)
        }
    }

    public private(set) var projectedValue: Persister<Value>

    public let defaultValue: Value?

    public init(persister: Persister<Value>, defaultValue: Value? = nil) {
        self.defaultValue = defaultValue
        projectedValue = persister
    }

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage
    ) where Storage.Value == Value {
        self.defaultValue = defaultValue

        projectedValue = Persister(key: key, storedBy: storage)
    }

    public init<Storage: Persist.Storage>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage
    ) where Storage.Value == Any {
        self.defaultValue = defaultValue

        projectedValue = Persister(key: key, storedBy: storage)
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        transformer: Transformer
    ) where Storage.Value == Any, Transformer.Input == Value {
        self.defaultValue = defaultValue

        projectedValue = Persister(key: key, storedBy: storage, transformer: transformer)
    }

    public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
        key: Storage.Key,
        defaultValue: Value? = nil,
        storedBy storage: Storage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == Storage.Value {
        self.defaultValue = defaultValue

        projectedValue = Persister(key: key, storedBy: storage, transformer: transformer)
    }

}
