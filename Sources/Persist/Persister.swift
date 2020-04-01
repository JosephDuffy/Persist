public struct Persister<Value> {

    public let key: String

    public private(set) var storage: Storage

    private let transform: AnyOutputTransform<Value>?

    private let untransform: AnyOutputUntransform<Value>?

    public init<Transformer: Persist.Transformer>(key: String, storedBy storage: Storage, transformer: Transformer) where Transformer.Input == Value {
        self.key = key
        self.storage = storage
        transform = transformer.anyOutputTransform()
        untransform = transformer.anyOutputUntransform()
    }

    public init(key: String, storedBy storage: Storage) {
        self.key = key
        self.storage = storage
        transform = nil
        untransform = nil
    }

    mutating func persist(_ value: Value, ofType: Value.Type = Value.self) throws {
        if let transform = transform {
            let transformedValue = try transform(value)
            try storage.storeValue(transformedValue, key: key)
        } else {
            try? storage.storeValue(value, key: key)
        }
    }

    mutating func removeValue() throws {
        try storage.removeValue(for: key)
    }

    mutating func retrieveValue(ofType: Value.Type = Value.self) throws -> Value? {
        if let untransform = untransform {
            guard let storedValue: Any = try storage.retrieveValue(for: key) else { return nil }
            return try untransform(storedValue)
        } else {
            return try storage.retrieveValue(for: key)
        }
    }
}

private typealias AnyOutputTransform<Input> = (_ value: Input) throws -> Any
private typealias AnyOutputUntransform<Input> = (_ output: Any) throws -> Input

extension Transformer {

    fileprivate func anyOutputTransform() -> AnyOutputTransform<Input> {
        return { value in
            return try self.transformValue(value)
        }
    }

    fileprivate func anyOutputUntransform() -> AnyOutputUntransform<Input> {
        return { anyOutput in
            guard let output = anyOutput as? Output else {
                throw PersistanceError.unexpectedValueType(value: anyOutput, expected: Output.self)
            }
            return try self.untransformValue(from: output)
        }
    }

}
