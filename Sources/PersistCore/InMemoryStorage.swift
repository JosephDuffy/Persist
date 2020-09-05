import Foundation

/**
 Storage that stores values in memory; values will not be persisted between app launches or instances of `InMemoryStorage`.
 */
open class InMemoryStorage<StoredValue>: Storage {
    /// The type the `InMemoryStorage` can store.
    public typealias Value = StoredValue

    private var dictionary: [String: StoredValue] = [:]

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    /**
     Create a new empty instance of `InMemoryStorage`.
     */
    public init() {}

    /**
     Store the provided value against the specified key.

     - parameter value: The value to store.
     - parameter key: The key to store the value against.
     */
    open func storeValue(_ value: StoredValue, key: String) {
        dictionary[key] = value

        updateListeners[key]?.values.forEach { $0(value) }
    }

    /**
     Removes the value for the provide key.

     - parameter key: The key of the value to be removed.
     */
    open func removeValue(for key: String) {
        dictionary.removeValue(forKey: key)

        updateListeners[key]?.values.forEach { $0(nil) }
    }

    /**
     Returns the value for the provided key, or `nil` if the value does not exist.

     - parameter key: The key of the value to retrieve.
     - returns: The stored value, or `nil` if the a value does not exist for the specified key.
     */
    open func retrieveValue(for key: String) -> StoredValue? {
        return dictionary[key]
    }

    /**
     Add a closure that will be called when the specified key is updated.

     - parameter key: The key to listen for changes to.
     - parameter updateListener: The closure to call when an update occurs.
     - returns: An object that represents the closure's subscription to changes. This object must be retained by the caller.
     */
    open func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> AnyCancellable {
        let uuid = UUID()

        updateListeners[key, default: [:]][uuid] = updateListener

        return Subscription { [weak self] in
            self?.updateListeners[key]?.removeValue(forKey: uuid)
        }.eraseToAnyCancellable()
    }

}
