import Foundation

/**
 Storage that stores values in memory; values will not be persisted between app launches or instances of `InMemoryStorage`.
 */
open class InMemoryStorage<StoredValue>: Storage {
    public typealias Value = StoredValue

    private var dictionary: [String: StoredValue] = [:]

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    public init() {}

    open func storeValue(_ value: StoredValue, key: String) {
        dictionary[key] = value

        updateListeners[key]?.values.forEach { $0(value) }
    }

    open func removeValue(for key: String) {
        dictionary.removeValue(forKey: key)

        updateListeners[key]?.values.forEach { $0(nil) }
    }

    open func retrieveValue(for key: String) -> StoredValue? {
        return dictionary[key]
    }

    open func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable {
        let uuid = UUID()

        updateListeners[key, default: [:]][uuid] = updateListener

        return Cancellable { [weak self] in
            self?.updateListeners[key]?.removeValue(forKey: uuid)
        }
    }

}
