import Foundation

public typealias PersistedInUserDefaults<Value> = Persisted<Value, UserDefaults>

extension UserDefaults: Storage {

    public func storeValue<Value>(_ value: Value, key: String) {
        if let url = value as? URL {
            set(url, forKey: key)
        } else {
            set(value, forKey: key)
        }
    }

    public func removeValue(for key: String) {
        removeObject(forKey: key)
    }

    public func retrieveValue<Value>(for key: String) throws -> Value? {
        if Value.self == URL.self {
            return url(forKey: key) as! Value?
        }

        guard let object = self.object(forKey: key) else { return nil }
        guard let value = object as? Value else {
            throw PersistanceError.unexpectedValueType(value: object, expected: Value.self)
        }
        return value
    }

    public func addUpdateListener(forKey key: String, updateListener: @escaping (Any?) -> Void) -> Cancellable {
        let observer = KeyPathObserver(updateListener: updateListener)
        addObserver(observer, forKeyPath: key, options: .new, context: nil)
        let cancellable = Cancellable { [weak self] in
            self?.removeObserver(observer, forKeyPath: key)
        }
        return cancellable
    }

}

private final class KeyPathObserver: NSObject {
    private let updateListener: (Any?) -> Void

    fileprivate init(updateListener: @escaping (Any?) -> Void) {
        self.updateListener = updateListener
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, (object as? UserDefaults)?.object(forKey: keyPath) is Data, let url = (object as? UserDefaults)?.url(forKey: keyPath) {
            updateListener(url)
        } else {
            updateListener(change?[.newKey])
        }
    }
}
