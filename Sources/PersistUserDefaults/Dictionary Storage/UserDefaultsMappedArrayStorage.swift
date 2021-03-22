#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation
import PersistCore

/// Stores an array of `Model`s in `UserDefaults` by creating a dictionary for each model.
///
/// Each dictionary is managed by an instance of `UserDefaultsArrayDictionaryStorage`
public final class UserDefaultsMappedArrayStorage<Model: StoredInUserDefaultsDictionary>: Storage {
    public enum StoreValueError: Error {
        /// A value cannot be stored when one does not currently exist.
        case valueDoesNotExist
        /// A value passed to `storeValue` was created outside of this storage instance.
        case valueCreatedIllegally(Model)
    }

    public typealias ModelBuilder<Model> = (_ storage: UserDefaultsArrayDictionaryStorage) throws -> Model

    /// The key used to access the array of models.
    public typealias Key = String

    public typealias Value = [Model]

    /// A dictionary of the cached `UserDefaultsArrayDictionaryStorage` used for each value.
    ///
    /// The first dictionary is keyed by the `UserDefaults` key used to access the array
    /// of dictionaries. The second dictionary is keyed by the identifier of the stored model.
    private typealias Storages = [Key: [String: UserDefaultsArrayDictionaryStorage]]

    private let modelBuilder: ModelBuilder<Model>

    private lazy var storagesQueue = DispatchQueue(label: "UserDefaultsMappedArrayStorage.storages")

    private let storagesLock = NSLock()

    private var storages: Storages = [:]

    private let userDefaultsStorage: UserDefaultsStorage

    public init(userDefaults: UserDefaults, modelBuilder: @escaping ModelBuilder<Model>) {
        userDefaultsStorage = UserDefaultsStorage(userDefaults: userDefaults)
        self.modelBuilder = modelBuilder
    }

    public func createNewValue(forKey key: String, modelBuilder: ModelBuilder<Model>) throws -> Model {
        storagesLock.lock()

        let newIndex: Int = try { () -> Int in
            let value = userDefaultsStorage.retrieveValue(for: key)

            switch value {
            case .none:
                return 0
            case .some(.array(let array)):
                return array.endIndex
            case .some(let value):
                throw PersistenceError.unexpectedValueType(value: value, expected: [Any].self)
            }
        }()

        let storage = UserDefaultsArrayDictionaryStorage(arrayKey: key, arrayIndex: newIndex, userDefaults: userDefaultsStorage.userDefaults)
        storage.creatingValue = true
        let model = try modelBuilder(storage)
        assert(storages[key, default: [:]][model.id] == nil, "Storage should not be created as a side effect of creating the model")
        storages[key, default: [:]][model.id] = storage
        storagesLock.unlock()
        try storage.persistCreatedValues()
        return model
    }

    public func storeValue(_ models: [Model], key: String) throws {
        guard let value = userDefaultsStorage.retrieveValue(for: key) else {
            throw StoreValueError.valueDoesNotExist
        }

        switch value {
        case .array(let array):
            var newArray = [Int: UserDefaultsValue]()

            storagesLock.lock()

            let storages = try models.map { model -> UserDefaultsArrayDictionaryStorage in
                guard let storage = self.storages[key]?[model.id] else {
                    throw StoreValueError.valueCreatedIllegally(model)
                }
                return storage
            }

            storages.enumerated().forEach { (newIndex, storage) in
                let oldIndex = storage.arrayIndex
                newArray[newIndex] = array[oldIndex]
                storage.arrayIndex = newIndex
            }

            storagesLock.unlock()

            let sortedArray = newArray.sorted { lhs, rhs in
                lhs.key < rhs.key
            }.map(\.value)

            userDefaultsStorage.storeValue(.array(sortedArray), key: key)
        default:
            throw PersistenceError.unexpectedValueType(value: value.value, expected: [Any].self)
        }
    }

    public func removeValue(for key: String) {
        userDefaultsStorage.removeValue(for: key)
    }

    public func retrieveValue(for key: String) throws -> [Model]? {
        guard let value = userDefaultsStorage.retrieveValue(for: key) else { return nil }
        return try mapValue(value, forKey: key)
    }

    public func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> AnyCancellable {
        userDefaultsStorage.addUpdateListener(forKey: key) { [weak self] value in
            guard let self = self else { return }

            if let value = value {
                guard let mappedValue = try? self.mapValue(value, forKey: key) else { return }
                updateListener(mappedValue)
            } else {
                updateListener(nil)
            }
        }
    }

    private func mapValue(_ value: UserDefaultsValue, forKey key: String) throws -> [Model] {
        switch value {
        case .array(let array):
            storagesLock.lock()

            let existingStorages = storages[key, default: [:]]
            let modelsAndStorage = array.indices.compactMap { index -> (model: Model, storage: UserDefaultsArrayDictionaryStorage)? in
                let userDefaultsValue = array[index]
                switch userDefaultsValue {
                case .dictionary(let dictionary):
                    guard let modelId = dictionary[Model.idUserDefaultsKey]?.cast(to: String.self) else { return nil }

                    if let existingStorage = existingStorages.first(where: { $0.key == modelId })?.value {
                        guard let model = try? modelBuilder(existingStorage) else { return nil }
                        return (model, existingStorage)
                    } else {
                        let newStorage = UserDefaultsArrayDictionaryStorage(
                            arrayKey: key,
                            arrayIndex: index,
                            userDefaults: userDefaultsStorage.userDefaults
                        )
                        guard let model = try? modelBuilder(newStorage) else { return nil }
                        return (model, newStorage)
                    }
                default:
                    return nil
                }
            }
            storages[key] = modelsAndStorage.reduce(into: [String: UserDefaultsArrayDictionaryStorage](), { (storages, element) in
                let (model, storage) = element
                storages[model.id] = storage
            })

            storagesLock.unlock()

            return modelsAndStorage.map(\.model)
        default:
            throw PersistenceError.unexpectedValueType(value: value, expected: [Any].self)
        }
    }
}
#endif
