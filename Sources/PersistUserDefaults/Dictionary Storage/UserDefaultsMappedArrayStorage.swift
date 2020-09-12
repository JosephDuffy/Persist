#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation
import PersistCore

/// Stores an array of `Model`s in `UserDefaults` by creating a dictionary for each model.
///
/// Each dictionary is managed by an instance of `UserDefaultsArrayDictionaryStorage`
public final class UserDefaultsMappedArrayStorage<Model: StoredInUserDefaultsDictionary>: Storage {
    public enum Error: Swift.Error {
        /// A value passed to `storeValue` was created outside of this storage instance.
        case valueCreatedIllegally(Model)
    }

    public typealias ModelBuilder<Model> = (_ storage: UserDefaultsArrayDictionaryStorage) throws -> Model

    public typealias Key = String

    public typealias Value = [Model]

    private let modelBuilder: ModelBuilder<Model>

    private var storages: [String: UserDefaultsArrayDictionaryStorage] = [:]

    private let userDefaultsStorage: UserDefaultsStorage

    public init(userDefaults: UserDefaults, modelBuilder: @escaping ModelBuilder<Model>) {
        userDefaultsStorage = UserDefaultsStorage(userDefaults: userDefaults)
        self.modelBuilder = modelBuilder
    }

    public func createNewValue(forKey key: String, modelBuilder: @escaping ModelBuilder<Model>) throws -> Model {
        let newIndex: Int = try {
            let value = userDefaultsStorage.retrieveValue(for: key)

            switch value {
            case .none:
                userDefaultsStorage.storeValue(
                    .array([
                        .dictionary(
                            [:]
                        )
                    ]),
                    key: key
                )
                return 0
            case .some(.array(var array)):
                array.append(.dictionary([:]))
                userDefaultsStorage.storeValue(.array(array), key: key)
                return array.endIndex - 1
            case .some(let value):
                throw PersistenceError.unexpectedValueType(value: value, expected: [Any].self)
            }
        }()

        let storage = UserDefaultsArrayDictionaryStorage(arrayKey: key, arrayIndex: newIndex, userDefaults: userDefaultsStorage.userDefaults)
        let model = try modelBuilder(storage)
        storages[model.id] = storage
        return model
    }

    public func storeValue(_ models: [Model], key: String) throws {
        try models.enumerated().forEach { (index, model) in
            guard let storage = storages[model.id] else {
                throw Error.valueCreatedIllegally(model)
            }

            storage.arrayIndex = index
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
            let modelsAndStorage = try array.indices.map { index -> (model: Model, storage: UserDefaultsArrayDictionaryStorage) in
                let storage = UserDefaultsArrayDictionaryStorage(arrayKey: key, arrayIndex: index)
                return (try modelBuilder(storage), storage)
            }

            storages = modelsAndStorage.reduce(into: [String: UserDefaultsArrayDictionaryStorage](), { (storages, element) in
                let (model, storage) = element
                storages[model.id] = storage
            })

            return modelsAndStorage.map(\.model)
        default:
            throw PersistenceError.unexpectedValueType(value: value, expected: [Any].self)
        }
    }
}
#endif
