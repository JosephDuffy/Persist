#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

internal final class ArrayKeyPathObserver: NSObject {
    internal typealias UpdateListener = (_ old: UserDefaultsValue?, _ new: UserDefaultsValue?) -> Void

    private let updateListener: UpdateListener

    internal init(updateListener: @escaping UpdateListener) {
        self.updateListener = updateListener
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        /*if let keyPath = keyPath, (object as? UserDefaults)?.object(forKey: keyPath) is Data, let url = (object as? UserDefaults)?.url(forKey: keyPath) {
            updateListener(.url(url))
         } else*/ if let change = change, let newValue = change[.newKey], let oldValue = change[.oldKey] {
            guard
                let newUserDefaultsValue = userDefaultsValue(for: newValue),
                let oldUserDefaultsValue = userDefaultsValue(for: oldValue)
            else {
                return
            }

            updateListener(oldUserDefaultsValue, newUserDefaultsValue)
        }
    }

    private func userDefaultsValue(for value: Any) -> UserDefaultsValue?? {
        if value is NSNull {
            return UserDefaultsValue?.none
        } else if let propertyListValue = UserDefaultsValue(value: value) {
            return propertyListValue
        } else {
            return nil
        }
    }
}
#endif
