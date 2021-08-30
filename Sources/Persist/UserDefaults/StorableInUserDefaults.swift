#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `UserDefaults`. This protocol is used to provide
 type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInUserDefaults {}

internal protocol InternalStorableInUserDefaults: StorableInUserDefaults {
    /// The value of `self` cast to `UserDefaultsValue`.
    var asUserDefaultsValue: UserDefaultsValue { get }
}

extension String: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.string` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .string(self)
    }
}

extension Data: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.data` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .data(self)
    }
}

extension URL: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.url` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .url(self)
    }
}

extension Bool: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.bool` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .bool(self)
    }
}

extension Int: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.int` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .int(self)
    }
}

extension Double: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.double` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .double(self)
    }
}

extension Float: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.float` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .float(self)
    }
}

extension Date: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.date` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .date(self)
    }
}

extension Array: StorableInUserDefaults where Element: StorableInUserDefaults {}

extension Array: InternalStorableInUserDefaults where Element: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.array` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .array(map(\.asUserDefaultsValue))
    }
}

extension Dictionary: StorableInUserDefaults where Key == String, Value: StorableInUserDefaults {}

extension Dictionary: InternalStorableInUserDefaults where Key == String, Value: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.dictionary` wrapping `self`.
    internal var asUserDefaultsValue: UserDefaultsValue {
        return .dictionary(mapValues(\.asUserDefaultsValue))
    }
}
#endif
