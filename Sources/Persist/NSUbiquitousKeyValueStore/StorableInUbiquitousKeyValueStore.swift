#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `NSUbiquitousKeyValueStore`. This protocol is
 used to provide type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInNSUbiquitousKeyValueStore {
    /// The value of `self` cast to `NSUbiquitousKeyValueStoreValue`.
    var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue { get }
}

extension String: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.string` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .string(self)
    }
}

extension Data: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.data` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .data(self)
    }
}

extension Bool: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.bool` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .bool(self)
    }
}

extension Int64: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.int64` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .int64(self)
    }
}

extension Double: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.double` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .double(self)
    }
}

extension Array: StorableInNSUbiquitousKeyValueStore where Element: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.array` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .array(map(\.asNSUbiquitousKeyValueStoreValue))
    }
}

extension Dictionary: StorableInNSUbiquitousKeyValueStore where Key == String, Value: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.dictionary` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .dictionary(mapValues(\.asNSUbiquitousKeyValueStoreValue))
    }
}
#endif
