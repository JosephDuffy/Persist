#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `UserDefaults`. This protocol is used to provide
 type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInUserDefaults {}

internal protocol InternalStorableInUserDefaults: StorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> Self?

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String)
}

extension String: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

extension Data: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> Data? {
        userDefaults.data(forKey: key)
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

extension URL: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> URL? {
        if let url = userDefaults.url(forKey: key), userDefaults.object(forKey: key) is Data {
            // `url(forKey:)` will return a URL for values that were not set as
            // URLs. URLs are stored in UserDefaults as Data so checking
            // `value(forKey:) is Data` ensures the value retrieved was set to
            // a URL.
            return url
        } else {
            return nil
        }
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

extension Bool: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> Bool? {
        if userDefaults.object(forKey: key) != nil {
            return userDefaults.bool(forKey: key)
        } else {
            return nil
        }
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

extension Int: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> Int? {
        if userDefaults.object(forKey: key) != nil {
            return userDefaults.integer(forKey: key)
        } else {
            return nil
        }
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

extension Double: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> Double? {
        if userDefaults.object(forKey: key) != nil {
            return userDefaults.double(forKey: key)
        } else {
            return nil
        }
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

extension Float: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> Float? {
        if userDefaults.object(forKey: key) != nil {
            return userDefaults.float(forKey: key)
        } else {
            return nil
        }
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

extension Date: InternalStorableInUserDefaults {
    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> Date? {
        userDefaults.object(forKey: key) as? Date
    }

    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
        userDefaults.set(self, forKey: key)
    }
}

//extension Array: StorableInUserDefaults where Element: StorableInUserDefaults {}

//extension Array where Element == String {
//    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> [String]? {
//        userDefaults.stringArray(forKey: key)
//    }
//
//    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
//        userDefaults.set(self, forKey: key)
//    }
//}

//extension Array: InternalStorableInUserDefaults where Element: InternalStorableInUserDefaults {
//    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> [Element]? {
//        userDefaults.array(forKey: key) as? Self
//    }
//
//    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
//        userDefaults.set(self, forKey: key)
//    }
//}
//
//extension Dictionary: StorableInUserDefaults where Key == String {}
//
//extension Dictionary: InternalStorableInUserDefaults where Key == String {
//    static func getFromUserDefaults(_ userDefaults: UserDefaults, key: String) -> [String: Element]? {
//        userDefaults.dictionary(forKey: key) as? [String: Element]
//    }
//
//    func storeInUserDefaults(_ userDefaults: UserDefaults, key: String) {
//        userDefaults.set(self, forKey: key)
//    }
//}
#endif
