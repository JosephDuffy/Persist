import Foundation

public enum UserDefaultsValue: Hashable {
    case string(String)
    case data(Data)
    case url(URL)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case float(Float)
    indirect case array([UserDefaultsValue])
    indirect case dictionary([String: UserDefaultsValue])

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

    internal init?(value: Any) {
        if let string = value as? String {
            self = .string(string)
        } else if let data = value as? Data {
            self = .data(data)
        } else if let url = value as? URL {
            self = .url(url)
        } else if let int = value as? Int, value is Int {
            self = .int(int)
        } else if let double = value as? Double, value is Double {
            self = .double(double)
        } else if let float = value as? Float, value is Float {
            self = .float(float)
        } else if let bool = value as? Bool, value is Bool {
            self = .bool(bool)
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
