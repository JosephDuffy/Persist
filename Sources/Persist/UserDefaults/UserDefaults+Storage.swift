import Foundation

extension UserDefaults: Storage {

    public typealias Value = UserDefaultsValue

    public func storeValue(_ value: UserDefaultsValue, key: String) {
        switch value {
        case .url(let url):
            set(url, forKey: key)
        default:
            set(value.value, forKey: key)
        }
    }

    public func removeValue(for key: String) {
        removeObject(forKey: key)
    }

    public func retrieveValue(for key: String) -> UserDefaultsValue? {
        if let url = self.url(forKey: key), value(forKey: key) is Data {
            // `url(forKey:)` will return a URL for values that were not set as
            // URLs. URLs are stored in UserDefaults as Data so checking
            // `value(forKey:) is Data` ensures the value retrieved was set to
            // a URL.
            return .url(url)
        } else if let anyValue = value(forKey: key) {
            return UserDefaultsValue(value: anyValue)
        } else {
            return nil
        }
    }

    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable {
        let observer = KeyPathObserver(updateListener: updateListener)
        addObserver(observer, forKeyPath: key, options: .new, context: nil)
        let cancellable = Cancellable { [weak self] in
            self?.removeObserver(observer, forKeyPath: key)
        }
        return cancellable
    }

}

private final class KeyPathObserver: NSObject {
    private let updateListener: UserDefaults.UpdateListener

    fileprivate init(updateListener: @escaping UserDefaults.UpdateListener) {
        self.updateListener = updateListener
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, (object as? UserDefaults)?.object(forKey: keyPath) is Data, let url = (object as? UserDefaults)?.url(forKey: keyPath) {
            updateListener(.url(url))
        } else {
            if let newValue = change?[.newKey] {
                guard let propertyListValue = UserDefaultsValue(value: newValue) else { return }
                updateListener(propertyListValue)
            } else {
                updateListener(nil)
            }
        }
    }
}
