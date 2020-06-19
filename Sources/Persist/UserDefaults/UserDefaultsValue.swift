#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/**
 A value that can be stored in `UserDefaults`.
 */
public enum UserDefaultsValue: Hashable {
    /// A `String` value.
    case string(String)

    /// A `Data` value.
    case data(Data)

    /// A `URL` value.
    case url(URL)

    /// A `Bool` value.
    case bool(Bool)

    /// An `Int` value.
    case int(Int)

    /// A `Double` value.
    case double(Double)

    /// A `Float` value.
    case float(Float)

    /// An `Array` value.
    indirect case array([UserDefaultsValue])

    /// A `Dictionary` value.
    indirect case dictionary([String: UserDefaultsValue])

    /**
     Case the value to the provided type. This is required because `UserDefaults` stores `Bool`s as `Int`s.
     */
    internal func cast<Type>(to type: Type.Type) -> Type? {
        switch self {
        case .int(let int):
            if type == Bool.self, int == 0 {
                return false as? Type
            } else if type == Bool.self, int == 1 {
                return true as? Type
            } else {
                return int as? Type
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
        case .bool(let bool):
            return bool
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .float(let float):
            return float
        case .array(let array):
            return array.map(\.value)
        case .dictionary(let dictionary):
            return dictionary.mapValues(\.value)
        }
    }

    /**
     Attempt to create a new instance from the provided value.

     - parameter value: The underlying value.
     - returns: An instance of `UserDefaultsValue`, or `nil` if the provided `value` is not
        storable in `UserDefaults`.
     */
    internal init?(value: Any) {
        if let string = value as? String {
            self = .string(string)
        } else if let data = value as? Data {
            self = .data(data)
        } else if let url = value as? URL {
            self = .url(url)
        } else if let int = value as? Int, value is Int {
            self = .int(int)
        } else if let bool = value as? Bool, value is Bool {
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
