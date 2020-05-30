#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

public enum NSUbiquitousKeyValueStoreValue: Hashable {
    case string(String)
    case data(Data)
    case bool(Bool)
    case int64(Int64)
    case double(Double)
    indirect case array([NSUbiquitousKeyValueStoreValue])
    indirect case dictionary([String: NSUbiquitousKeyValueStoreValue])

    var value: Any {
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
