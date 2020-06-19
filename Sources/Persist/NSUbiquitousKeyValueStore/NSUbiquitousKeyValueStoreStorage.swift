#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public final class NSUbiquitousKeyValueStoreStorage: Storage {

    public static var `default`: Self {
        return Self(nsUbiquitousKeyValueStore: .default)
    }

    public typealias Value = NSUbiquitousKeyValueStoreValue

    public let nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    public required init(nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore) {
        self.nsUbiquitousKeyValueStore = nsUbiquitousKeyValueStore
    }

    public func storeValue(_ value: NSUbiquitousKeyValueStoreValue, key: String) {
        nsUbiquitousKeyValueStore.set(value.value, forKey: key)

        updateListeners[key]?.values.forEach { $0(value) }
    }

    public func removeValue(for key: String) {
        nsUbiquitousKeyValueStore.removeObject(forKey: key)

        updateListeners[key]?.values.forEach { $0(nil) }
    }

    public func retrieveValue(for key: String) -> NSUbiquitousKeyValueStoreValue? {
        guard let anyValue = nsUbiquitousKeyValueStore.object(forKey: key) else {
            return nil
        }

        return NSUbiquitousKeyValueStoreValue(value: anyValue)
    }

    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Subscription {
        return addUpdateListener(forKey: key, notificationCenter: .default, updateListener: updateListener)
    }

    public func addUpdateListener(forKey key: String, notificationCenter: NotificationCenter, updateListener: @escaping UpdateListener) -> Subscription {
        let notificationObserver = notificationCenter.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nsUbiquitousKeyValueStore,
            queue: nil
        ) { [weak self] notification in
            guard let self = self else { return }
            guard let keys = notification.userInfo?[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
            guard keys.contains(key) else { return }

            let newValue = self.retrieveValue(for: key)
            updateListener(newValue)
        }
        
        let uuid = UUID()

        updateListeners[key, default: [:]][uuid] = updateListener

        let subscription = Subscription { [weak self] in
            self?.updateListeners[key]?.removeValue(forKey: uuid)

            notificationCenter.removeObserver(
                notificationObserver,
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: self?.nsUbiquitousKeyValueStore
            )
        }
        return subscription
    }

}
#endif
