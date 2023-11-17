//#if os(macOS) || os(iOS) || os(tvOS)
//import Foundation
//
///**
// A value that can be stored in `NSUbiquitousKeyValueStore`.
// */
//internal enum NSUbiquitousKeyValueStoreValue: Hashable {
//    /// A `Bool` value. Convenience to convert to `NSNumber`.
//    /// - Parameter bool: The boolean value.
//    /// - Returns: A `UserDefaultsValue.number`.
//    internal static func bool(_ bool: Bool) -> Self {
//        .number(bool as NSNumber)
//    }
//
//    /// An `Int64` value. Convenience to convert to `NSNumber`.
//    /// - Parameter int64: The 64-bit integer value.
//    /// - Returns: A `UserDefaultsValue.number`.
//    internal static func int64(_ int64: Int64) -> Self {
//        .number(int64 as NSNumber)
//    }
//
//    /// A `Double` value. Convenience to convert to `NSNumber`.
//    /// - Parameter double: The double value.
//    /// - Returns: A `UserDefaultsValue.number`.
//    internal static func double(_ double: Double) -> Self {
//        .number(double as NSNumber)
//    }
//
//    /// A `String` value.
//    case string(String)
//
//    /// A `Data` value.
//    case data(Data)
//
//    /// An `NSNumber` value. This will only contain a `Bool`, `Int64`, or `Double``
//    case number(NSNumber)
//
//    /// An array of `NSUbiquitousKeyValueStoreValue` values.
//    indirect case array([NSUbiquitousKeyValueStoreValue])
//
//    /// Dictionary of `NSUbiquitousKeyValueStoreValue` values keyed by `String`s.
//    indirect case dictionary([String: NSUbiquitousKeyValueStoreValue])
//
//    /**
//     Case the value to the provided type. This is required because `NSUbiquitousKeyValueStoreValue`
//     stores `Bool`s as `Int64`s.
//     */
//    internal func cast<Type>(to type: Type.Type) -> Type? {
//        switch self {
//        case .number(let nsNumber):
//            if type == Bool.self {
//                return nsNumber.boolValue as? Type
//            } else if type == Double.self {
//                return nsNumber.doubleValue as? Type
//            } else if type == Int64.self {
//                return nsNumber.int64Value as? Type
//            } else {
//                return nsNumber as? Type
//            }
//        default:
//            return value as? Type
//        }
//    }
//
//    /// The underlying value.
//    internal var value: Any {
//        switch self {
//        case .string(let string):
//            return string
//        case .data(let data):
//            return data
//        case .number(let nsNumber):
//            return nsNumber
//        case .array(let array):
//            return array.map(\.value)
//        case .dictionary(let dictionary):
//            return dictionary.mapValues(\.value)
//        }
//    }
//
//    /**
//     Attempt to create a new instance from the provided value.
//
//     - parameter value: The underlying value.
//     - returns: An instance of `NSUbiquitousKeyValueStoreValue`, or `nil` if the provided
//        `value` is not storable in `NSUbiquitousKeyValueStore`.
//     */
//    internal init?(value: Any) {
//        if let string = value as? String {
//            self = .string(string)
//        } else if let data = value as? Data {
//            self = .data(data)
//        } else if let int64 = value as? Int64 {
//            self = .int64(int64)
//        } else if let double = value as? Double {
//            self = .double(double)
//        } else if let bool = value as? Bool {
//            self = .bool(bool)
//        } else if let anyArray = value as? [Any] {
//            var array: [NSUbiquitousKeyValueStoreValue] = []
//
//            for anyValue in anyArray {
//                guard let UbiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue(value: anyValue) else { return nil }
//                array.append(UbiquitousKeyValueStoreValue)
//            }
//
//            self = .array(array)
//        } else if let anyDictionary = value as? [String: Any] {
//            var dictionary: [String: NSUbiquitousKeyValueStoreValue] = [:]
//
//            for (key, anyValue) in anyDictionary {
//                guard let UbiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue(value: anyValue) else { return nil }
//                dictionary[key] = UbiquitousKeyValueStoreValue
//            }
//
//            self = .dictionary(dictionary)
//        } else {
//            return nil
//        }
//    }
//}
//#endif
