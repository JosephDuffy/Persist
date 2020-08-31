#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `NSUbiquitousKeyValueStore`. This protocol is
 used to provide type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInNSUbiquitousKeyValueStore {}

internal protocol InternalStorableInNSUbiquitousKeyValueStore: StorableInNSUbiquitousKeyValueStore {
    /// The value of `self` cast to `NSUbiquitousKeyValueStoreValue`.
    var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue { get }
}

extension String: InternalStorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.string` wrapping `self`.
    internal var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .string(self)
    }
}

extension Data: InternalStorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.data` wrapping `self`.
    internal var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .data(self)
    }
}

extension Bool: InternalStorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.bool` wrapping `self`.
    internal var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .bool(self)
    }
}

extension Int64: InternalStorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.int64` wrapping `self`.
    internal var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .int64(self)
    }
}

extension Double: InternalStorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.double` wrapping `self`.
    internal var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .double(self)
    }
}

extension Array: StorableInNSUbiquitousKeyValueStore where Element: StorableInNSUbiquitousKeyValueStore {}

extension Array: InternalStorableInNSUbiquitousKeyValueStore where Element: InternalStorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.array` wrapping `self`.
    internal var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .array(map(\.asNSUbiquitousKeyValueStoreValue))
    }
}

extension Dictionary: StorableInNSUbiquitousKeyValueStore where Key == String, Value: StorableInNSUbiquitousKeyValueStore {}

extension Dictionary: InternalStorableInNSUbiquitousKeyValueStore where Key == String, Value: InternalStorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.dictionary` wrapping `self`.
    internal var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .dictionary(mapValues(\.asNSUbiquitousKeyValueStoreValue))
    }
}
#endif
