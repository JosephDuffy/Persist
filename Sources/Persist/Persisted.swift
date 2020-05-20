import Foundation

@propertyWrapper
public struct Persisted<Value, Storage: Persist.Storage> {

    public var wrappedValue: Value? {
        mutating get {
            return (try? projectedValue.retrieveValue()) ?? defaultValue
        }
        set {
            if let newValue = newValue {
                try? projectedValue.persist(newValue)
            } else {
                try? projectedValue.removeValue()
            }
        }
    }

    public private(set) var projectedValue: Persister<Value, Storage>

    public let defaultValue: Value?

    public init(defaultValue: Value? = nil, storedBy persister: Persister<Value, Storage>) {
        self.defaultValue = defaultValue
        self.projectedValue = persister
    }

    public init(key: Storage.Key, defaultValue: Value? = nil, storedBy storage: Storage) {
        self.defaultValue = defaultValue
        self.projectedValue = Persister(key: key, storedBy: storage)
    }

    public init<Transformer: Persist.Transformer>(key: Storage.Key, defaultValue: Value? = nil, storedBy storage: Storage, transformer: Transformer) where Transformer.Input == Value {
        self.defaultValue = defaultValue
        self.projectedValue = Persister(key: key, storedBy: storage, transformer: transformer)
    }

}
