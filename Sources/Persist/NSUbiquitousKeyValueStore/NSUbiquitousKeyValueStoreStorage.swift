//#if os(macOS) || os(iOS) || os(tvOS)
//import Foundation
//
///**
// A `Storage` wrapper around an `NSUbiquitousKeyValueStore` instance.
// */
//internal final class NSUbiquitousKeyValueStoreStorage: Storage {
//
//    /// The value type the `NSUbiquitousKeyValueStoreStorage` can store.
//    internal typealias Value = NSUbiquitousKeyValueStoreValue
//
//    /// The `NSUbiquitousKeyValueStore` this instance wraps.
//    internal let nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore
//
//    private var updateListeners: [String: [UUID: UpdateListener]] = [:]
//
//    /**
//     Create a new instance that wraps the specified `NSUbiquitousKeyValueStore`.
//
//     - parameter nsUbiquitousKeyValueStore: The store to use to store and retrieve values.
//     */
//    internal required init(nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore) {
//        self.nsUbiquitousKeyValueStore = nsUbiquitousKeyValueStore
//    }
//
//    /**
//     Store the provided value against the specified key.
//
//     - parameter value: The value to store.
//     - parameter key: The key to store the value against.
//     */
//    internal func storeValue(_ value: NSUbiquitousKeyValueStoreValue, key: String) {
//        nsUbiquitousKeyValueStore.set(value.value, forKey: key)
//
//        updateListeners[key]?.values.forEach { $0(value) }
//    }
//
//    /**
//     Removes the value for the provide key.
//
//     - parameter key: The key of the value to be removed.
//     */
//    internal func removeValue(for key: String) {
//        nsUbiquitousKeyValueStore.removeObject(forKey: key)
//
//        updateListeners[key]?.values.forEach { $0(nil) }
//    }
//
//    /**
//     Returns the value for the provided key, or `nil` if the value does not exist.
//
//     - parameter key: The key of the value to retrieve.
//     - returns: The stored value, or `nil` if the a value does not exist for the specified key.
//     */
//    internal func retrieveValue(for key: String) -> NSUbiquitousKeyValueStoreValue? {
//        guard let anyValue = nsUbiquitousKeyValueStore.object(forKey: key) else {
//            return nil
//        }
//
//        return NSUbiquitousKeyValueStoreValue(value: anyValue)
//    }
//
//    /**
//     Add a closure that will be called when the specified key is updated.
//
//     - parameter key: The key to listen for changes to.
//     - parameter updateListener: The closure to call when an update occurs.
//     - returns: An object that represents the closure's subscription to changes. This object must be retained by the caller.
//     */
//    internal func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> AnyCancellable {
//        return addUpdateListener(forKey: key, notificationCenter: .default, updateListener: updateListener)
//    }
//
//    /**
//     Add a closure that will be called when the specified key is updated, using the provided notification center to subscribe the changes.
//
//     - parameter key: The key to listen for changes to.
//     - parameter notificationCenter: The notification center to use to observe for changes.
//     - parameter updateListener: The closure to call when an update occurs.
//     - returns: An object that represents the closure's subscription to changes. This object must be retained by the caller.
//    */
//    internal func addUpdateListener(forKey key: String, notificationCenter: NotificationCenter, updateListener: @escaping UpdateListener) -> AnyCancellable {
//        let notificationObserver = notificationCenter.addObserver(
//            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
//            object: nsUbiquitousKeyValueStore,
//            queue: nil
//        ) { [weak self] notification in
//            guard let self = self else { return }
//            guard let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
//            guard keys.contains(key) else { return }
//
//            let newValue = self.retrieveValue(for: key)
//            updateListener(newValue)
//        }
//        
//        let uuid = UUID()
//
//        updateListeners[key, default: [:]][uuid] = updateListener
//
//        return Subscription { [weak self] in
//            self?.updateListeners[key]?.removeValue(forKey: uuid)
//
//            notificationCenter.removeObserver(
//                notificationObserver,
//                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
//                object: self?.nsUbiquitousKeyValueStore
//            )
//        }.eraseToAnyCancellable()
//    }
//
//}
//#endif
