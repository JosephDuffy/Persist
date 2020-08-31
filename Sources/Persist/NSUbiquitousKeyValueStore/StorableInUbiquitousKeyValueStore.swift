#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

/**
 A protocol that indicates that a value can be stored in `NSUbiquitousKeyValueStore`. This protocol is
 used to provide type safety and should not be conformed to outside of Persist.
 */
public protocol StorableInNSUbiquitousKeyValueStore {
    /// The value of `self` cast to `NSUbiquitousKeyValueStoreValue`.
    var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue { get }

    /// Do not implement this protocol or retrieve this value (it will crash your program). It is for internal use only.
    var doNotImplementStorableInNSUbiquitousKeyValueStore: Never { get }
}

extension String: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.string` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .string(self)
    }

    public var doNotImplementStorableInNSUbiquitousKeyValueStore: Never {
        fatalError(#function + " should not be called")
    }
}

extension Data: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.data` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .data(self)
    }

    public var doNotImplementStorableInNSUbiquitousKeyValueStore: Never {
        fatalError(#function + " should not be called")
    }
}

extension Bool: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.bool` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .bool(self)
    }

    public var doNotImplementStorableInNSUbiquitousKeyValueStore: Never {
        fatalError(#function + " should not be called")
    }
}

extension Int64: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.int64` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .int64(self)
    }

    public var doNotImplementStorableInNSUbiquitousKeyValueStore: Never {
        fatalError(#function + " should not be called")
    }
}

extension Double: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.double` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .double(self)
    }

    public var doNotImplementStorableInNSUbiquitousKeyValueStore: Never {
        fatalError(#function + " should not be called")
    }
}

extension Array: StorableInNSUbiquitousKeyValueStore where Element: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.array` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .array(map(\.asNSUbiquitousKeyValueStoreValue))
    }

    public var doNotImplementStorableInNSUbiquitousKeyValueStore: Never {
        fatalError(#function + " should not be called")
    }
}

extension Dictionary: StorableInNSUbiquitousKeyValueStore where Key == String, Value: StorableInNSUbiquitousKeyValueStore {
    /// An `NSUbiquitousKeyValueStoreValue.dictionary` wrapping `self`.
    public var asNSUbiquitousKeyValueStoreValue: NSUbiquitousKeyValueStoreValue {
        return .dictionary(mapValues(\.asNSUbiquitousKeyValueStoreValue))
    }

    public var doNotImplementStorableInNSUbiquitousKeyValueStore: Never {
        fatalError(#function + " should not be called")
    }
}
#endif
