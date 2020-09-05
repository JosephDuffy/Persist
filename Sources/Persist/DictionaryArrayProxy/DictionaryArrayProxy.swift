public final class DictionaryArrayProxy<Key: Hashable, Value>: Storage {
    public var index: Int

    private let persister: Persister<[[Key: Value]]>

    public init(index: Int, persister: Persister<[[Key: Value]]>) {
        self.index = index
        self.persister = persister
    }

    public func storeValue(_ value: Value, key: Key) throws {
        var array = try persister.retrieveValueOrThrow()
        array[index][key] = value
        try persister.persist(array)
    }

    public func removeValue(for key: Key) throws {
        var array = try persister.retrieveValueOrThrow()
        array[index].removeValue(forKey: key)
        try persister.persist(array)
    }

    public func retrieveValue(for key: Key) throws -> Value? {
        try persister.retrieveValueOrThrow()[index][key]
    }

    public func addUpdateListener(forKey key: Key, updateListener: @escaping UpdateListener) -> AnyCancellable {
        fatalError(#function + " is unsupported")
    }
}

struct Foo {
    @Persisted
    var integer: Int

    @Persisted
    var string: String

    init<Storage: Persist.Storage>(storage: Storage) where Storage.Key == String, Storage.Value == Any {
        _integer = Persisted(key: "integer", storedBy: storage, defaultValue: 123)
        _string = Persisted(key: "string", storedBy: storage, defaultValue: "")
    }
}

//public final class ProxyStorage<Key, Value>: Storage {
//    public typealias StoreValue = (_ value: Value, _ key: Key) throws -> Void
//    public typealias RemoveValue = (_ key: Key) throws -> Void
//    public typealias RetrieveValue = (_ key: Key) throws -> Value?
//
//    private let _storeValue: StoreValue
//    private let _removeValue: RemoveValue
//    private let _retrieveValue: RetrieveValue
//
//    public init(storeValue: @escaping StoreValue, removeValue: @escaping RemoveValue, retrieveValue: @escaping RetrieveValue) {
//        _storeValue = storeValue
//        _removeValue = removeValue
//        _retrieveValue = retrieveValue
//    }
//
//    public func storeValue(_ value: Value, key: Key) throws {
//        try _storeValue(value, key)
//    }
//
//    public func removeValue(for key: Key) throws {
//        try _removeValue(key)
//    }
//
//    public func retrieveValue(for key: Key) throws -> Value? {
//        try _retrieveValue(key)
//    }
//
//    public func addUpdateListener(forKey key: Key, updateListener: @escaping UpdateListener) -> AnyCancellable {
//        fatalError(#function + " is unsupported")
//    }
//}

//extension Persister {
//    public static func dictionaryArrayPersister<Element>() -> Persister<[Element]> {
//        var elements: [Element] = []
//        return Persister<[Element]>(
//            valueGetter: {
//                return elements
//            },
//            valueSetter: { newValue in
//                elements = newValue
//            },
//            valueRemover: <#T##ValueRemover##ValueRemover##() throws -> Void#>,
//            defaultValue: <#T##Value#>,
//            addUpdateListener: <#T##(@escaping UpdateListener, @escaping () -> Value) -> AnyCancellable#>
//        )
//    }
//}
//
//public final class DictionaryArrayStorage<Key, Element, ElementKey: Hashable, ElementValue>: Storage {
//    public typealias InstanceBuilder = (_ persister: Storage) -> Value
//
//    public typealias Value = [Element]
//
//    public typealias Persister = Persist.Persister<[[ElementKey: ElementValue]]>
//
//    private var elements: Value
//
//    public func storeValue(_ value: [Element], key: Key) throws {
//        <#code#>
//    }
//
//    public func removeValue(for key: Key) throws {
//        <#code#>
//    }
//
//    public func retrieveValue(for key: Key) throws -> [Element]? {
//        <#code#>
//    }
//
//    public func addUpdateListener(forKey key: Key, updateListener: @escaping UpdateListener) -> AnyCancellable {
//        <#code#>
//    }
//}

//public final class DictionaryStorage<Storage: Persist.Storage, Value>: Persist.Storage {
////    public typealias ParentPersister = Persister<[Dictionary]>
//    public typealias InstanceBuilder = (_ persister: Storage) -> Value
//
//    private let persister: ParentPersister
//
//    public init(persister: ParentPersister) {
//        self.persister = persister
//    }
//}
//
//public final class PersistedDictionaryStorage<Value: Equatable>: Storage {
//    public typealias Key = String
//
//    private let persister: Persister<[String: Value]>
//
//    private var lastKnownValue: [String: Value]
//
//    public init(persister: Persister<[String: Value]>) {
//        self.persister = persister
//        lastKnownValue = persister.retrieveValue()
//    }
//
//    public func storeValue(_ value: Value, key: String) throws {
//        var dictionary = try persister.retrieveValueOrThrow()
//        dictionary[key] = value
//        try persister.persist(dictionary)
//    }
//
//    public func removeValue(for key: String) throws {
//        var dictionary = try persister.retrieveValueOrThrow()
//        dictionary.removeValue(forKey: key)
//        try persister.persist(dictionary)
//    }
//
//    public func retrieveValue(for key: String) throws -> Value? {
//        let dictionary = try persister.retrieveValueOrThrow()
//        return dictionary[key]
//    }
//
//    public func addUpdateListener(forKey key: String, updateListener: @escaping (Value?) -> Void) -> AnyCancellable {
//        return persister.addUpdateListener { [weak self] result in
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let update):
//                defer {
//                    self.lastKnownValue = update.newValue
//                }
//
//                if update.newValue[key] != self.lastKnownValue[key] {
//                    updateListener(update.newValue[key])
//                }
//            case .failure:
//                break
//            }
//        }
//    }
//}
