import Foundation

/**
 Storage that stores values in memory; values will not be persisted between app launches or instances of `InMemoryStorage`.
 */
open class InMemoryStorage: Storage {

    private var dictionary: [String: Any] = [:]

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    public init() {}

    open func storeValue<Value>(_ value: Value, key: String) {
        dictionary[key] = value

        updateListeners[key]?.values.forEach { $0(value) }
    }

    open func removeValue(for key: String) {
        dictionary.removeValue(forKey: key)

        updateListeners[key]?.values.forEach { $0(nil) }
    }

    open func retrieveValue<Value>(for key: String) throws -> Value? {
        guard let anyValue = dictionary[key] else { return nil }
        guard let value = anyValue as? Value else {
            throw PersistanceError.unexpectedValueType(value: anyValue, expected: Value.self)
        }
        return value
    }

    open func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable {
        let uuid = UUID()

        updateListeners[key, default: [:]][uuid] = updateListener

        return Cancellable { [weak self] in
            self?.updateListeners[key]?.removeValue(forKey: uuid)
        }
    }

}
