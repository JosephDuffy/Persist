#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation
import PersistCore

public final class UserDefaultsArrayDictionaryStorage: Storage {
    public enum Error: Swift.Error {
        case indexOutOfBounds(_ index: Int)
    }

    public typealias Key = String

    public typealias Value = UserDefaultsValue

    public let arrayKey: String

    public var arrayIndex: Int

    private let userDefaults: UserDefaults

    private let backingStorage: UserDefaultsStorage

    public init(arrayKey: String, arrayIndex: Int, userDefaults: UserDefaults = .standard) {
        self.arrayKey = arrayKey
        self.arrayIndex = arrayIndex
        self.userDefaults = userDefaults
        backingStorage = UserDefaultsStorage(userDefaults: userDefaults)
    }

    public func storeValue(_ value: UserDefaultsValue, key: String) throws {
        var array = try getArray()

        if array.indices.contains(arrayIndex) {
            array[arrayIndex][key] = value
        } else if array.endIndex == arrayIndex {
            var dictionary = [String: UserDefaultsValue]()
            dictionary[key] = value
            array.append(dictionary)
        } else {
            throw Error.indexOutOfBounds(arrayIndex)
        }

        backingStorage.storeValue(.array(array.map { UserDefaultsValue.dictionary($0) }), key: arrayKey)
    }

    public func removeValue(for key: String) throws {
        var array = try getArray()

        guard array.indices.contains(arrayIndex) else {
            throw Error.indexOutOfBounds(arrayIndex)
        }

        array[arrayIndex].removeValue(forKey: key)

        backingStorage.storeValue(.array(array.map { UserDefaultsValue.dictionary($0) }), key: arrayKey)
    }

    public func retrieveValue(for key: String) throws -> UserDefaultsValue? {
        let array = try getArray()

        guard array.indices.contains(arrayIndex) else {
            throw Error.indexOutOfBounds(arrayIndex)
        }

        return array[arrayIndex][key]
    }

    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> AnyCancellable {
        let observer = KeyPathObserver(updateListener: updateListener)
        let key = arrayKey + "[\(arrayIndex)].\(key)"
        userDefaults.addObserver(observer, forKeyPath: key, options: .new, context: nil)
        return Subscription { [weak userDefaults] in
            userDefaults?.removeObserver(observer, forKeyPath: key)
        }.eraseToAnyCancellable()
    }

    private func getArray() throws -> [[String: UserDefaultsValue]] {
        if let value = backingStorage.retrieveValue(for: arrayKey) {
            switch value {
            case .array(let array):
                return try array.map { element -> [String : UserDefaultsValue] in
                    switch element {
                    case .dictionary(let dictionary):
                        return dictionary
                    default:
                        throw PersistenceError.unexpectedValueType(value: element, expected: [String: Any].self)
                    }
                }

            default:
                throw PersistenceError.unexpectedValueType(value: value, expected: [Any].self)
            }
        } else {
            return []
        }
    }
}
#endif
