#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A `Storage` wrapper around a `UserDefaults` instance.
 */
public final class UserDefaultsStorage: Storage {

    /// The value type the `UserDefaultsStorage` can store.
    public typealias Value = UserDefaultsValue

    /// An instance that wraps the `UserDefaults.standard` store.
    public static var standard: UserDefaultsStorage {
        return UserDefaultsStorage(userDefaults: .standard)
    }

    /// The `UserDefaults` this instance wraps.
    public let userDefaults: UserDefaults

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    /**
     Create a new instance that wraps the specified `UserDefaults`.

     - parameter userDefaults: The user defaults to use to store and retrieve values.
     */
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    /**
     Create a new instance that wraps an instance of `UserDefaults` with the provided suite name.

     See `UserDefaults.init(suiteName:)`.

     - parameter suiteName: The domain identifier of the search list.
     */
    public init?(suiteName: String?) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else { return nil }
        self.userDefaults = userDefaults
    }

    /**
     Store the provided value against the specified key.

     - parameter value: The value to store.
     - parameter key: The key to store the value against.
     */
    public func storeValue(_ value: UserDefaultsValue, key: String) {
        switch value {
        case .url(let url):
            userDefaults.set(url, forKey: key)
        default:
            userDefaults.set(value.value, forKey: key)
        }
    }

    /**
     Removes the value for the provide key.

     - parameter key: The key of the value to be removed.
     */
    public func removeValue(for key: String) {
        userDefaults.removeObject(forKey: key)
    }

    /**
     Returns the value for the provided key, or `nil` if the value does not exist.

     - parameter key: The key of the value to retrieve.
     - returns: The stored value, or `nil` if the a value does not exist for the specified key.
     */
    public func retrieveValue(for key: String) -> UserDefaultsValue? {
        if let url = userDefaults.url(forKey: key), userDefaults.object(forKey: key) is Data {
            // `url(forKey:)` will return a URL for values that were not set as
            // URLs. URLs are stored in UserDefaults as Data so checking
            // `value(forKey:) is Data` ensures the value retrieved was set to
            // a URL.
            return .url(url)
        } else if let anyValue = userDefaults.object(forKey: key) {
            return UserDefaultsValue(value: anyValue)
        }

        return nil
    }

    /**
     Add a closure that will be called when the specified key is updated.

     - parameter key: The key to listen for changes to.
     - parameter updateListener: The closure to call when an update occurs.
     - returns: An object that represents the closure's subscription to changes. This object must be retained by the caller.
     */
    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable {
        let observer = KeyPathObserver(updateListener: updateListener)
        userDefaults.addObserver(observer, forKeyPath: key, options: .new, context: nil)
        let subscription = Subscription { [weak userDefaults] in
            userDefaults?.removeObserver(observer, forKeyPath: key)
        }
        return subscription
    }

}

private final class KeyPathObserver: NSObject {
    private let updateListener: UserDefaultsStorage.UpdateListener

    fileprivate init(updateListener: @escaping UserDefaultsStorage.UpdateListener) {
        self.updateListener = updateListener
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, (object as? UserDefaults)?.object(forKey: keyPath) is Data, let url = (object as? UserDefaults)?.url(forKey: keyPath) {
            updateListener(.url(url))
        } else if let change = change, let newValue = change[.newKey] {
            if newValue is NSNull {
                updateListener(nil)
            } else if let propertyListValue = UserDefaultsValue(value: newValue) {
                updateListener(propertyListValue)
            }
        }
    }
}
#endif
