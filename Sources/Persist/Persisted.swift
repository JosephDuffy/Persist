import Foundation

@propertyWrapper
public struct Persisted<Value> {

    public var wrappedValue: Value {
        mutating get {
            return (try? projectedValue.retrieveValue()) ?? defaultValue
        }
        set {
            try? projectedValue.persist(newValue)
        }
    }

    public private(set) var projectedValue: Persister<Value>

    public let defaultValue: Value

    public init(defaultValue: Value, storedBy persister: Persister<Value>) {
        self.defaultValue = defaultValue
        self.projectedValue = persister
    }

    public init(key: String, defaultValue: Value, storedBy storage: Storage, lock: Lock) {
        self.defaultValue = defaultValue
        self.projectedValue = Persister(key: key, storedBy: storage, lock: lock)
    }

    public init<Transformer: Persist.Transformer>(key: String, defaultValue: Value, storedBy storage: Storage, transformer: Transformer, lock: Lock) where Transformer.Input == Value {
        self.defaultValue = defaultValue
        self.projectedValue = Persister(key: key, storedBy: storage, transformer: transformer, lock: lock)
    }

}

extension Persisted where Value: ExpressibleByNilLiteral {

    public init(defaultValue: Value = nil, storedBy persister: Persister<Value>) {
        self.defaultValue = defaultValue
        self.projectedValue = persister
    }

    public init(key: String, defaultValue: Value = nil, storedBy storage: Storage, lock: Lock) {
        self.defaultValue = defaultValue
        self.projectedValue = Persister(key: key, storedBy: storage, lock: lock)
    }

    public init<Transformer: Persist.Transformer>(key: String, defaultValue: Value = nil, storedBy storage: Storage, transformer: Transformer, lock: Lock) where Transformer.Input == Value {
        self.defaultValue = defaultValue
        self.projectedValue = Persister(key: key, storedBy: storage, transformer: transformer, lock: lock)
    }

}
