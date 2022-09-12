import Foundation

/**
 Storage that stores values in memory; values will not be persisted between app launches or instances of `InMemoryStorage`.
 */
open class InMemoryStorage<StoredValue>: Storage {
    /// The type the `InMemoryStorage` can store.
    public typealias Value = StoredValue

    private var dictionary: [String: StoredValue] = [:]

    private var dictionaryLock = NSLock()

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    private var updateListenersLock = NSLock()

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
        dictionaryLock.lock()
        dictionary[key] = value
        dictionaryLock.unlock()

        updateListenersLock.lock()
        // Take a copy of the update listeners so the lock can be unlocked when
        // the closures are called, preventing a deadlock if a subscriber adds
        // a new subscription is response to an update.
        let updateListenersForKey = updateListeners[key]?.values
        updateListenersLock.unlock()

        updateListenersForKey?.forEach { $0(value) }
    }

    /**
     Removes the value for the provide key.

     - parameter key: The key of the value to be removed.
     */
    open func removeValue(for key: String) {
        dictionaryLock.lock()
        dictionary.removeValue(forKey: key)
        dictionaryLock.unlock()

        updateListenersLock.lock()
        // Take a copy of the update listeners so the lock can be unlocked when
        // the closures are called, preventing a deadlock if a subscriber adds
        // a new subscription is response to an update.
        let updateListenersForKey = updateListeners[key]?.values
        updateListenersLock.unlock()

        updateListenersForKey?.forEach { $0(nil) }
    }

    /**
     Returns the value for the provided key, or `nil` if the value does not exist.

     - parameter key: The key of the value to retrieve.
     - returns: The stored value, or `nil` if the a value does not exist for the specified key.
     */
    open func retrieveValue(for key: String) -> StoredValue? {
        dictionaryLock.lock()
        let value = dictionary[key]
        dictionaryLock.unlock()
        return value
    }

    /**
     Add a closure that will be called when the specified key is updated.

     - parameter key: The key to listen for changes to.
     - parameter updateListener: The closure to call when an update occurs.
     - returns: An object that represents the closure's subscription to changes. This object must be retained by the caller.
     */
    open func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> AnyCancellable {
        let uuid = UUID()

        updateListenersLock.lock()
        updateListeners[key, default: [:]][uuid] = updateListener
        updateListenersLock.unlock()

        return Subscription { [weak self] in
            guard let self = self else { return }
            self.updateListenersLock.lock()
            self.updateListeners[key]?.removeValue(forKey: uuid)
            self.updateListenersLock.unlock()
        }.eraseToAnyCancellable()
    }
}
