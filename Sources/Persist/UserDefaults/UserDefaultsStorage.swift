#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

public final class UserDefaultsStorage: Storage {

    public typealias Value = UserDefaultsValue

    public static var standard: UserDefaultsStorage {
        return UserDefaultsStorage(userDefaults: .standard)
    }

    public let userDefaults: UserDefaults

    private var updateListeners: [String: [UUID: UpdateListener]] = [:]

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public init?(suiteName: String?) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else { return nil }
        self.userDefaults = userDefaults
    }

    public func storeValue(_ value: UserDefaultsValue, key: String) {
        switch value {
        case .url(let url):
            userDefaults.set(url, forKey: key)
        default:
            userDefaults.set(value.value, forKey: key)
        }
    }

    public func removeValue(for key: String) {
        userDefaults.removeObject(forKey: key)
    }

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

    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable {
        let observer = KeyPathObserver(updateListener: updateListener)
        userDefaults.addObserver(observer, forKeyPath: key, options: .new, context: nil)
        let cancellable = Cancellable { [weak userDefaults] in
            userDefaults?.removeObserver(observer, forKeyPath: key)
        }
        return cancellable
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
