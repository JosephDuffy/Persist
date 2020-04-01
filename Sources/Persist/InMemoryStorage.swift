/**
 Storage that only persists value in memory; values will not be persisted between app launches or instances of `InMemoryStorage`.
 */
public struct InMemoryStorage: Storage {

    private var dictionary: [String: Any] = [:]

    public init() {}

    public mutating func storeValue<Value>(_ value: Value, key: String) throws {
        dictionary[key] = value
    }

    public mutating func removeValue(for key: String) throws {
        dictionary.removeValue(forKey: key)
    }

    public func retrieveValue<Value>(for key: String) throws -> Value? {
        guard let anyValue = dictionary[key] else { return nil }
        guard let value = anyValue as? Value else {
            throw PersistanceError.unexpectedValueType(value: anyValue, expected: Value.self)
        }
        return value
    }

    public mutating func storeValue<Value>(_ value: Value, key: String, ofType type: Value.Type) throws {
        try storeValue(value, key: key)
    }

}
