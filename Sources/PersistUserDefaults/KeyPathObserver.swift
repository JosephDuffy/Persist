#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

internal final class KeyPathObserver: NSObject {
    private let updateListener: UserDefaultsStorage.UpdateListener

    internal init(updateListener: @escaping UserDefaultsStorage.UpdateListener) {
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
