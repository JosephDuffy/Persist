#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public protocol StorableInUbiquitousKeyValueStore {
    var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue { get }
}

extension String: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .string(self)
    }
}

extension Data: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .data(self)
    }
}

extension Bool: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .bool(self)
    }
}

extension Int64: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .int64(self)
    }
}

extension Double: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .double(self)
    }
}

extension Array: StorableInUbiquitousKeyValueStore where Element: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .array(map(\.asUbiquitousKeyValueStoreValue))
    }
}

extension Dictionary: StorableInUbiquitousKeyValueStore where Key == String, Value: StorableInUbiquitousKeyValueStore {
    public var asUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .dictionary(mapValues(\.asUbiquitousKeyValueStoreValue))
    }
}
#endif
