#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `UserDefaults`. This protocol is used to provide
 type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInUserDefaults {}

public protocol InternalStorableInUserDefaults: StorableInUserDefaults {
    /// The value of `self` cast to `UserDefaultsValue`.
    var asUserDefaultsValue: UserDefaultsValue { get }
}

extension String: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.string` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .string(self)
    }
}

extension Data: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.data` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .data(self)
    }
}

extension URL: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.url` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .url(self)
    }
}

extension Bool: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.bool` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .bool(self)
    }
}

extension Int: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.int` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .int(self)
    }
}

extension Double: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.double` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .double(self)
    }
}

extension Float: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.float` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .float(self)
    }
}

extension NSNumber: InternalStorableInUserDefaults {
    /// A `UserDefaultsValue.number` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .number(self)
    }
}

extension Date: InternalStorableInUserDefaults {
    /// A `UserDefaultsValue.date` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .date(self)
    }
}

extension Array: StorableInUserDefaults where Element: StorableInUserDefaults {}

extension Array: InternalStorableInUserDefaults where Element: InternalStorableInUserDefaults {
    /// An `UserDefaultsValue.array` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .array(map(\.asUserDefaultsValue))
    }
}

extension Dictionary: StorableInUserDefaults where Key == String {}

extension Dictionary: InternalStorableInUserDefaults where Key == String {
    /// An `UserDefaultsValue.dictionary` wrapping `self`.
    public var asUserDefaultsValue: UserDefaultsValue {
        return .dictionary(compactMapValues { $0 as? InternalStorableInUserDefaults }.mapValues(\.asUserDefaultsValue))
    }
}
#endif
