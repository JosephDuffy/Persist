@attached(peer, names: suffixed(_storage), suffixed(_cache))
@attached(accessor)
public macro Persist<Key>(key: Key, storage: any Storage<Key>, cacheValue: Bool = false) = #externalMacro(module: "PersistMacros", type: "Persist")

@attached(peer, names: suffixed(_storage), suffixed(_cache))
@attached(accessor)
public macro Persist<Key, Root, Storage: Persist.Storage<Key>>(key: Key, storage: KeyPath<Root, Storage>, cacheValue: Bool = false) = #externalMacro(module: "PersistMacros", type: "Persist")

@attached(peer, names: suffixed(_storage), suffixed(_cache))
@attached(accessor)
public macro Persist<Key>(key: Key, storage: any MutatingStorage<Key>, cacheValue: Bool = false) = #externalMacro(module: "PersistMacros", type: "Persist_Mutating")

@attached(peer, names: suffixed(_storage), suffixed(_cache))
@attached(accessor)
public macro Persist<Key, Root, MutatingStorage: Persist.MutatingStorage<Key>>(key: Key, storage: KeyPath<Root, MutatingStorage>, cacheValue: Bool = false) = #externalMacro(module: "PersistMacros", type: "Persist_Mutating")

import Foundation

public struct UserDefaultsStorage: Storage, Sendable {
    private var userDefaults: UserDefaults {
        _userDefaults()
    }

    private let _userDefaults: @Sendable () -> UserDefaults

    public init(_ userDefaults: @autoclosure @escaping @Sendable () -> UserDefaults) {
        self._userDefaults = userDefaults
    }

    public func getValue<Value>(forKey key: String) -> Value? {
        userDefaults.value(forKey: key) as? Value
    }

    public func getValue(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    public func getValue(forKey key: String) -> [Any]? {
        userDefaults.array(forKey: key)
    }

    public func getValue(forKey key: String) -> [String: Any]? {
        userDefaults.dictionary(forKey: key)
    }

    public func getValue(forKey key: String) -> Data? {
        userDefaults.data(forKey: key)
    }

    public func getValue(forKey key: String) -> [String]? {
        userDefaults.stringArray(forKey: key)
    }

    public func getValue(forKey key: String) -> Int? {
        userDefaults.integer(forKey: key)
    }

    public func getValue(forKey key: String) -> Float? {
        userDefaults.float(forKey: key)
    }

    public func getValue(forKey key: String) -> Double? {
        userDefaults.double(forKey: key)
    }

    public func getValue(forKey key: String) -> Bool? {
        userDefaults.bool(forKey: key)
    }

    public func getValue(forKey key: String) -> URL? {
        userDefaults.url(forKey: key)
    }

    public func setValue<Value>(_ value: Value, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func setValue(_ value: Int, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func setValue(_ value: URL, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

public struct DictionaryStorage: MutatingStorage {
    private var dictionary: [String: Any] = [:]

    public init() {}

    public func getValue<Value>(forKey key: String) -> Value? {
        dictionary[key] as? Value
    }

    public mutating func setValue<Value>(_ value: Value, forKey key: String) {
        dictionary[key] = value
    }

    public mutating func removeValue(forKey key: String) {
        dictionary.removeValue(forKey: key)
    }
}

public protocol Storage<Key> {
    /// The type of the key used to store values.
    associatedtype Key

    nonmutating func getValue<Value>(forKey key: Key) -> Value?

    nonmutating func setValue<Value>(_ value: Value, forKey key: Key)

    nonmutating func removeValue(forKey key: Key)
}

public protocol MutatingStorage<Key> {
    /// The type of the key used to store values.
    associatedtype Key

    func getValue<Value>(forKey key: Key) -> Value?

    mutating func setValue<Value>(_ value: Value, forKey key: Key)

    mutating func removeValue(forKey key: Key)
}

public protocol ThrowingStorage<Key> {
    /// The type of the key used to store values.
    associatedtype Key

    func getValue<Value>(forKey key: Key) throws -> Value?

    func setValue<Value>(_ value: Value, forKey key: Key) throws

    func removeValue(forKey key: Key) throws
}
