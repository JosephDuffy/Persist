import Foundation

/**
 Storage that only persists value in memory; values will not be persisted between app launches or instances of `InMemoryStorage`.
 */
open class InMemoryStorage: Storage {

    private var dictionary: [String: Any] = [:]

    private var updateListeners: [UUID: UpdateListener] = [:]

    public init() {}

    open func storeValue<Value>(_ value: Value, key: String) {
        dictionary[key] = value
    }

    open func removeValue(for key: String) {
        dictionary.removeValue(forKey: key)
    }

    open func retrieveValue<Value>(for key: String) throws -> Value? {
        guard let anyValue = dictionary[key] else { return nil }
        guard let value = anyValue as? Value else {
            throw PersistanceError.unexpectedValueType(value: anyValue, expected: Value.self)
        }
        return value
    }

    open func storeValue<Value>(_ value: Value, key: String, ofType type: Value.Type) {
        storeValue(value, key: key)
    }

    open func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable {
        let uuid = UUID()

        updateListeners[uuid] = updateListener

        return Cancellable { [weak self] in
            self?.updateListeners.removeValue(forKey: uuid)
        }
    }

}
