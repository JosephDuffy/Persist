#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation
import PersistCore

/// Storage that accesses an array of dictionaries stored in `UserDefaults`. You should not use this storage type directly. Instead
/// conform your type to `StoredInUserDefaultsDictionary` and use the `UserDefaultsMappedArrayStorage` storage
/// type with a `Persister` or `Persisted`.
public final class UserDefaultsArrayDictionaryStorage: Storage {
    public enum Error: Swift.Error {
        case indexOutOfBounds(_ index: Int)
    }

    public typealias Key = String

    public typealias Value = UserDefaultsValue

    public let arrayKey: String

    public internal(set) var arrayIndex: Int

    /// A flag used to indicate that the storage is being used to create a new value.
    ///
    /// When this flag is set no values will be persisted to `UserDefaults`.
    internal var creatingValue = false

    private lazy var createdValues: [String: UserDefaultsValue] = [:]

    private let userDefaults: UserDefaults

    private let backingStorage: UserDefaultsStorage

    public init(arrayKey: String, arrayIndex: Int, userDefaults: UserDefaults = .standard) {
        self.arrayKey = arrayKey
        self.arrayIndex = arrayIndex
        self.userDefaults = userDefaults
        backingStorage = UserDefaultsStorage(userDefaults: userDefaults)
    }

    public func storeValue(_ value: UserDefaultsValue, key: String) throws {
        guard !creatingValue else {
            createdValues[key] = value
            return
        }

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
        guard !creatingValue else {
            createdValues.removeValue(forKey: key)
            return
        }

        var array = try getArray()

        guard array.indices.contains(arrayIndex) else {
            throw Error.indexOutOfBounds(arrayIndex)
        }

        array[arrayIndex].removeValue(forKey: key)

        backingStorage.storeValue(.array(array.map { UserDefaultsValue.dictionary($0) }), key: arrayKey)
    }

    public func retrieveValue(for key: String) throws -> UserDefaultsValue? {
        guard !creatingValue else {
            return createdValues[key]
        }

        let array = try getArray()

        guard array.indices.contains(arrayIndex) else {
            throw Error.indexOutOfBounds(arrayIndex)
        }

        return array[arrayIndex][key]
    }

    public enum RetrieveValueError: Swift.Error {
        case valueMissing(key: String)
        case invalidValueType(value: UserDefaultsValue, expected: Any.Type)
    }

    public func retrieveValue<Type: StorableInUserDefaults>(for key: String, ofType type: Type.Type) throws -> Type {
        guard let value = try retrieveValue(for: key) else {
            throw RetrieveValueError.valueMissing(key: key)
        }

        guard let castValue = value.cast(to: Type.self) else {
            throw RetrieveValueError.invalidValueType(value: value, expected: Type.self)
        }

        return castValue
    }

    public func persister<Type: StorableInUserDefaults>(for key: String, ofType type: Type?.Type) throws -> Persister<Type?> {
        do {
            let currentValue = try retrieveValue(for: key, ofType: Type.self)
            return Persister(
                key: key,
                storedBy: self,
                transformer: StorableInUserDefaultsTransformer(),
                defaultValue: currentValue
            )
        } catch RetrieveValueError.valueMissing {
            return Persister(
                key: key,
                storedBy: self,
                transformer: StorableInUserDefaultsTransformer(),
                defaultValue: nil
            )
        } catch {
            throw error
        }
    }

    public func persister<Type: StorableInUserDefaults>(for key: String, ofType type: Type.Type) throws -> Persister<Type> {
        let currentValue = try retrieveValue(for: key, ofType: Type.self)
        return Persister(
            key: key,
            storedBy: self,
            transformer: StorableInUserDefaultsTransformer(),
            defaultValue: currentValue
        )
    }

    public func persister<Type, Transformer: PersistCore.Transformer>(
        for key: String,
        ofType type: Type?.Type,
        transformer: Transformer
    ) throws -> Persister<Type?> where Transformer.Input == Type, Transformer.Output: StorableInUserDefaults {
        guard let value = try retrieveValue(for: key) else {
            return Persister(
                key: key,
                storedBy: self,
                transformer: transformer.append(transformer: StorableInUserDefaultsTransformer()),
                defaultValue: nil
            )
        }

        guard let castValue = value.cast(to: Transformer.Output.self) else {
            throw RetrieveValueError.invalidValueType(value: value, expected: Type.self)
        }

        let currentValue = try transformer.untransformValue(castValue)

        return Persister(
            key: key,
            storedBy: self,
            transformer: transformer.append(transformer: StorableInUserDefaultsTransformer()),
            defaultValue: currentValue
        )
    }

    public func persister<Type, Transformer: PersistCore.Transformer>(
        for key: String,
        ofType type: Type.Type,
        transformer: Transformer
    ) throws -> Persister<Type> where Transformer.Input == Type, Transformer.Output: StorableInUserDefaults {
        guard let value = try retrieveValue(for: key) else {
            throw RetrieveValueError.valueMissing(key: key)
        }

        guard let castValue = value.cast(to: Transformer.Output.self) else {
            throw RetrieveValueError.invalidValueType(value: value, expected: Type.self)
        }

        let currentValue = try transformer.untransformValue(castValue)

        return Persister(
            key: key,
            storedBy: self,
            transformer: transformer.append(transformer: StorableInUserDefaultsTransformer()),
            defaultValue: currentValue
        )
    }

    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> AnyCancellable {
        let observer = ArrayKeyPathObserver { [weak self] oldValue, newValue in
            guard let self = self else { return }

            let oldUserDefaultsValue = oldValue.flatMap { self.value(forKey: key, in: $0) }
            let newUserDefaultsValue = newValue.flatMap { self.value(forKey: key, in: $0) }

            if oldUserDefaultsValue != newUserDefaultsValue {
                updateListener(newUserDefaultsValue)
            }
        }
        userDefaults.addObserver(observer, forKeyPath: arrayKey, options: [.old, .new], context: nil)
        return Subscription { [weak userDefaults, arrayKey] in
            userDefaults?.removeObserver(observer, forKeyPath: arrayKey)
        }.eraseToAnyCancellable()
    }

    internal func persistCreatedValues() throws {
        assert(creatingValue)

        creatingValue = false

        try createdValues.forEach { element in
            let (key, value) = element
            try storeValue(value, key: key)
        }

        createdValues = [:]
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
                        throw PersistenceError.unexpectedValueType(value: element, expected: [String: UserDefaultsValue].self)
                    }
                }

            default:
                throw PersistenceError.unexpectedValueType(value: value, expected: [[String: UserDefaultsValue]].self)
            }
        } else {
            return []
        }
    }

    private func value(forKey key: String, in userDefaultsValue: UserDefaultsValue) -> UserDefaultsValue? {
        switch userDefaultsValue {
        case .array(let array):
            guard array.indices.contains(arrayIndex) else {
                return nil
            }

            let element = array[arrayIndex]
            switch element {
            case .dictionary(let dictionary):
                return dictionary[key]
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
#endif
