#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

/**
 A value that can be stored in `NSUbiquitousKeyValueStore`.
 */
public enum NSUbiquitousKeyValueStoreValue: Hashable {
    /// A `String` value.
    case string(String)

    /// A `Data` value.
    case data(Data)

    /// A `Bool` value.
    case bool(Bool)

    /// An `Int64` value.
    case int64(Int64)

    /// A `Double` value.
    case double(Double)

    /// An array of `NSUbiquitousKeyValueStoreValue` values.
    indirect case array([NSUbiquitousKeyValueStoreValue])

    /// Dictionary of `NSUbiquitousKeyValueStoreValue` values keyed by `String`s.
    indirect case dictionary([String: NSUbiquitousKeyValueStoreValue])

    /**
     Case the value to the provided type. This is required because `NSUbiquitousKeyValueStoreValue`
     stores `Bool`s as `Int64`s.
     */
    internal func cast<Type>(to type: Type.Type) -> Type? {
        switch self {
        case .int64(let int64):
            if type == Bool.self {
                if int64 == 0 {
                    return false as? Type
                } else if int64 == 1 {
                    return true as? Type
                }
            }

            return int64 as? Type
        default:
            return value as? Type
        }
    }

    /// The underlying value.
    internal var value: Any {
        switch self {
        case .string(let string):
            return string
        case .data(let data):
            return data
        case .bool(let bool):
            return bool
        case .int64(let int64):
            return int64
        case .double(let double):
            return double
        case .array(let array):
            return array.map(\.value)
        case .dictionary(let dictionary):
            return dictionary.mapValues(\.value)
        }
    }

    /**
     Attempt to create a new instance from the provided value.

     - parameter value: The underlying value.
     - returns: An instance of `NSUbiquitousKeyValueStoreValue`, or `nil` if the provided
        `value` is not storable in `NSUbiquitousKeyValueStore`.
     */
    internal init?(value: Any) {
        if let string = value as? String {
            self = .string(string)
        } else if let data = value as? Data {
            self = .data(data)
        } else if let int64 = value as? Int64 {
            self = .int64(int64)
        } else if let double = value as? Double {
            self = .double(double)
        } else if let bool = value as? Bool {
            self = .bool(bool)
        } else if let anyArray = value as? [Any] {
            var array: [NSUbiquitousKeyValueStoreValue] = []

            for anyValue in anyArray {
                guard let UbiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue(value: anyValue) else { return nil }
                array.append(UbiquitousKeyValueStoreValue)
            }

            self = .array(array)
        } else if let anyDictionary = value as? [String: Any] {
            var dictionary: [String: NSUbiquitousKeyValueStoreValue] = [:]

            for (key, anyValue) in anyDictionary {
                guard let UbiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue(value: anyValue) else { return nil }
                dictionary[key] = UbiquitousKeyValueStoreValue
            }

            self = .dictionary(dictionary)
        } else {
            return nil
        }
    }
}
#endif
