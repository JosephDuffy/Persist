#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A value that can be stored in `UserDefaults`.
 */
public enum UserDefaultsValue: Hashable {
    /// A `Bool` value. Convenience to convert to `NSNumber`.
    /// - Parameter bool: The boolean value.
    /// - Returns: A `UserDefaultsValue.number`.
    static func bool(_ bool: Bool) -> Self {
        .number(bool as NSNumber)
    }

    /// An `Int` value. Convenience to convert to `NSNumber`.
    /// - Parameter int: The integer value.
    /// - Returns: A `UserDefaultsValue.number`.
    static func int(_ int: Int) -> Self {
        .number(int as NSNumber)
    }

    /// A `Double` value. Convenience to convert to `NSNumber`.
    /// - Parameter double: The double value.
    /// - Returns: A `UserDefaultsValue.number`.
    static func double(_ double: Double) -> Self {
        .number(double as NSNumber)
    }

    /// A `Float` value. Convenience to convert to `NSNumber`.
    /// - Parameter float: The float value.
    /// - Returns: A `UserDefaultsValue.number`.
    static func float(_ float: Float) -> Self {
        .number(float as NSNumber)
    }

    /// A `String` value.
    case string(String)

    /// A `Data` value.
    case data(Data)

    /// A `URL` value.
    case url(URL)

    case number(NSNumber)

    /// An `Array` value.
    indirect case array([UserDefaultsValue])

    /// A `Dictionary` value.
    indirect case dictionary([String: UserDefaultsValue])

    /**
     Cast the value to the provided type. This is required because `UserDefaults` stores `Bool`s,
     `Int`s, `Float`s, and `Double`s as `NSNumber`s so Swift will convert the type returned from
     `object(forKey:`). For example, storing the `Double` value `123` and calling `object(forKey:)`
     will return an `Int`.
     */
    internal func cast<Type>(to type: Type.Type) -> Type? {
        switch self {
        case .number(let nsNumber):
            if type == Bool.self {
                return nsNumber.boolValue as? Type
            } else if type == Float.self {
                return nsNumber.floatValue as? Type
            } else if type == Double.self {
                return nsNumber.doubleValue as? Type
            } else if type == Int.self {
                return nsNumber.intValue as? Type
            } else {
                return nsNumber as? Type
            }
        default:
            return value as? Type
        }
    }

    /// The underlying value.
    var value: Any {
        switch self {
        case .string(let string):
            return string
        case .data(let data):
            return data
        case .url(let url):
            return url
        case .number(let nsNumber):
            return nsNumber
        case .array(let array):
            return array.map(\.value)
        case .dictionary(let dictionary):
            return dictionary.mapValues(\.value)
        }
    }

    /**
     Attempt to create a new instance from the provided value.

     - parameter value: The underlying value.
     - returns: An instance of `UserDefaultsValue`, or `nil` if the provided `value` can not be
     stored in `UserDefaults`.
     */
    internal init?(value: Any) {
        if let string = value as? String {
            self = .string(string)
        } else if let data = value as? Data {
            self = .data(data)
        } else if let url = value as? URL {
            self = .url(url)
        } else if let int = value as? Int {
            self = .int(int)
        } else if let bool = value as? Bool {
            self = .bool(bool)
        } else if let float = value as? Float {
            self = .float(float)
        } else if let double = value as? Double {
            self = .double(double)
        } else if let anyArray = value as? [Any] {
            var array: [UserDefaultsValue] = []

            for anyValue in anyArray {
                guard let propertyListValue = UserDefaultsValue(value: anyValue) else { return nil }
                array.append(propertyListValue)
            }

            self = .array(array)
        } else if let anyDictionary = value as? [String: Any] {
            var dictionary: [String: UserDefaultsValue] = [:]

            for (key, anyValue) in anyDictionary {
                guard let propertyListValue = UserDefaultsValue(value: anyValue) else { return nil }
                dictionary[key] = propertyListValue
            }

            self = .dictionary(dictionary)
        } else {
            return nil
        }
    }
}
#endif
