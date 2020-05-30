#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public final class UbiquitousKeyValueStore: Storage {

    public static var `default`: Self {
        return Self(nsUbiquitousKeyValueStore: .default)
    }

    public typealias Value = UbiquitousKeyValueStoreValue

    public let nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    public required init(nsUbiquitousKeyValueStore: NSUbiquitousKeyValueStore) {
        self.nsUbiquitousKeyValueStore = nsUbiquitousKeyValueStore
    }

    public func storeValue(_ value: UbiquitousKeyValueStoreValue, key: String) {
        nsUbiquitousKeyValueStore.set(value.value, forKey: key)

        updateListeners[key]?.values.forEach { $0(value) }
    }

    public func removeValue(for key: String) {
        nsUbiquitousKeyValueStore.removeObject(forKey: key)

        updateListeners[key]?.values.forEach { $0(nil) }
    }

    public func retrieveValue(for key: String) -> UbiquitousKeyValueStoreValue? {
        if let anyValue = nsUbiquitousKeyValueStore.object(forKey: key) {
            return UbiquitousKeyValueStoreValue(value: anyValue)
        } else {
            return nil
        }
    }

    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable {
        return addUpdateListener(forKey: key, notificationCenter: .default, updateListener: updateListener)
    }

    public func addUpdateListener(forKey key: String, notificationCenter: NotificationCenter, updateListener: @escaping UpdateListener) -> Cancellable {
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

        let cancellable = Cancellable { [weak self] in
            self?.updateListeners[key]?.removeValue(forKey: uuid)

            notificationCenter.removeObserver(
                notificationObserver,
                name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: self?.nsUbiquitousKeyValueStore
            )
        }
        return cancellable
    }

}
#endif
