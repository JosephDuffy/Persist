#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public protocol StorableInNSUbiquitousKeyValueStore {
    var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue { get }
}

extension String: StorableInNSUbiquitousKeyValueStore {
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .string(self)
    }
}

extension Data: StorableInNSUbiquitousKeyValueStore {
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .data(self)
    }
}

extension Bool: StorableInNSUbiquitousKeyValueStore {
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .bool(self)
    }
}

extension Int64: StorableInNSUbiquitousKeyValueStore {
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .int64(self)
    }
}

extension Double: StorableInNSUbiquitousKeyValueStore {
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .double(self)
    }
}

extension Array: StorableInNSUbiquitousKeyValueStore where Element: StorableInNSUbiquitousKeyValueStore {
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .array(map(\.asNSUbiquitousKeyValueStoreValue))
    }
}

extension Dictionary: StorableInNSUbiquitousKeyValueStore where Key == String, Value: StorableInNSUbiquitousKeyValueStore {
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .dictionary(mapValues(\.asNSUbiquitousKeyValueStoreValue))
    }
}
#endif
