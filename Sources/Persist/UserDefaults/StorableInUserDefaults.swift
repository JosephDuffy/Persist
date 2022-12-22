#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `UserDefaults`. This protocol is used to provide
 type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInUserDefaults {}

/**
 A protocol that indicates that a value can be stored in a collection in
 `UserDefaults`, specifically arrays and dictionaries.

 This protocol is used to provide type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInUserDefaultsCollection: StorableInUserDefaults {}

internal protocol InternalStorableInUserDefaults: StorableInUserDefaults {
    /// The value of `self` cast to `UserDefaultsValue`.
    var asUserDefaultsValue: UserDefaultsValue { get }
}

internal protocol InternalStorableInUserDefaultsCollection: InternalStorableInUserDefaults & StorableInUserDefaultsCollection {}

extension String: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.string` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .string(self)
    }
}

extension Data: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.data` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .data(self)
    }
}

// URLs can only be stored as specific keys; they must be stored as strings in collections.
extension URL: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.url` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .url(self)
    }
}

extension Bool: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.bool` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .bool(self)
    }
}

extension Int: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.int` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .int(self)
    }
}

extension Double: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.double` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .double(self)
    }
}

extension Float: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.float` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .float(self)
    }
}

extension NSNumber: InternalStorableInUserDefaultsCollection {
    /// A `UserDefaultsValue.number` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .number(self)
    }
}

extension Date: InternalStorableInUserDefaultsCollection {
    /// A `UserDefaultsValue.date` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .date(self)
    }
}

extension Array: StorableInUserDefaults where Element: StorableInUserDefaultsCollection {}

extension Array: StorableInUserDefaultsCollection where Element: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.array` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .array(map(\.asUserDefaultsValue))
    }
}

extension Dictionary: StorableInUserDefaults where Key == String, Value: StorableInUserDefaultsCollection {}

extension Dictionary: StorableInUserDefaultsCollection where Key == String, Value: InternalStorableInUserDefaultsCollection {
    /// An `UserDefaultsValue.dictionary` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .dictionary(mapValues(\.asUserDefaultsValue))
    }
}
#endif
