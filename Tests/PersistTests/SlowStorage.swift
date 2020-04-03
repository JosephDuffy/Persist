import Persist
import Foundation

/**
 Storage that only persists value in memory and allows for artificial slowdowns.
 */
public final class SlowStorage: Storage {

    public var storeDelay: useconds_t?

    public var removeDelay: useconds_t?

    public var retrieveDelay: useconds_t?

    private var dictionary: [String: Any] = [:]

    public init() {}

    public func storeValue<Value>(_ value: Value, key: String) throws {
        _ = storeDelay.map(usleep)

        dictionary[key] = value
    }

    public func removeValue(for key: String) throws {
        _ = removeDelay.map(usleep)

        dictionary.removeValue(forKey: key)
    }

    public func retrieveValue<Value>(for key: String) throws -> Value? {
        _ = retrieveDelay.map(usleep)

        guard let anyValue = dictionary[key] else { return nil }
        guard let value = anyValue as? Value else {
            throw PersistanceError.unexpectedValueType(value: anyValue, expected: Value.self)
        }
        return value
    }

}
