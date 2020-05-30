#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

public protocol StorableInUserDefaults {
    var asUserDefaultsValue: UserDefaultsValue { get }
}

extension String: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .string(self)
    }
}

extension Data: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .data(self)
    }
}

extension URL: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .url(self)
    }
}

extension Bool: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .bool(self)
    }
}

extension Int: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .int(self)
    }
}

extension Double: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .double(self)
    }
}

extension Float: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .float(self)
    }
}

extension Array: StorableInUserDefaults where Element: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .array(map(\.asUserDefaultsValue))
    }
}

extension Dictionary: StorableInUserDefaults where Key == String, Value: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .dictionary(mapValues(\.asUserDefaultsValue))
    }
}
#endif
