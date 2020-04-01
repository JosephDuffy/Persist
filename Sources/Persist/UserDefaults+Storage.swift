import Foundation

extension UserDefaults: Storage {

    public func storeValue<Value>(_ value: Value, key: String) {
        set(value, forKey: key)
    }

    public func removeValue(for key: String) {
        removeObject(forKey: key)
    }

    public func retrieveValue<Value>(for key: String) throws -> Value? {
        guard let object = self.object(forKey: key) else { return nil }
        guard let value = object as? Value else {
            throw PersistanceError.unexpectedValueType(value: object, expected: Value.self)
        }
        return value
    }

}
