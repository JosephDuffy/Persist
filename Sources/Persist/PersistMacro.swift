@attached(peer, names: suffixed(_storage), suffixed(_cache))
@attached(accessor)
public macro Persist<Key>(
    key: Key,
    storage: any Storage<Key>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_Storage_NoTransformer")

@attached(peer, names: suffixed(_cache))
@attached(accessor)
public macro Persist<Key, Root, Storage: Persist.Storage<Key>>(
    key: Key,
    storage: KeyPath<Root, Storage>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_Storage_NoTransformer")

@attached(peer, names: suffixed(_storage), suffixed(_cache))
@attached(accessor)
public macro Persist<Key>(
    key: Key,
    storage: any MutatingStorage<Key>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_MutatingStorage_NoTransformer")

@attached(peer, names: suffixed(_cache))
@attached(accessor)
public macro Persist<Key, Root, MutatingStorage: Persist.MutatingStorage<Key>>(
    key: Key,
    storage: KeyPath<Root, MutatingStorage>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_MutatingStorage_NoTransformer")

@attached(peer, names: suffixed(_storage), suffixed(_cache))
@attached(accessor)
public macro Persist<Key>(
    key: Key,
    storage: any ThrowingStorage<Key>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_ThrowingStorage_NoTransformer")

@attached(peer, names: suffixed(_cache))
@attached(accessor)
public macro Persist<Key, Root, ThrowingStorage: Persist.ThrowingStorage<Key>>(
    key: Key,
    storage: KeyPath<Root, ThrowingStorage>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_ThrowingStorage_NoTransformer")

@attached(peer, names: suffixed(_storage), suffixed(_cache), suffixed(_transformer))
@attached(accessor)
public macro Persist<Key, Input, Output>(
    key: Key,
    storage: any Storage<Key>,
    transformer: any ThrowingTransformer<Input, Output>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_Storage_ThrowingTransformer")

// User Defaults

@attached(peer, names: suffixed(_storage), prefixed(`$`), suffixed(_cache))
@attached(accessor)
public macro Persist(
    key: String,
    userDefaults: UserDefaults,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_UserDefaults_NoTransformer")

@attached(peer, names: suffixed(_storage), prefixed(`$`), suffixed(_cache))
@attached(accessor)
public macro Persist<Root>(
    key: String,
    userDefaults: KeyPath<Root, UserDefaults>,
    cacheValue: Bool = false
) = #externalMacro(module: "PersistMacros", type: "Persist_UserDefaults_NoTransformer")

import Foundation

public struct UpdateListenerWrapper<Value>: Sendable {
    public typealias ValuesStreamProvider = @Sendable () -> AsyncStream<Value>

    private let valuesStreamProvider: ValuesStreamProvider

    public init(valuesStreamProvider: @escaping ValuesStreamProvider) {
        self.valuesStreamProvider = valuesStreamProvider
    }

    public func addUpdateListener(_ updateListener: @Sendable @escaping (_ value: Value) -> Void) -> any Cancellable {
        let task = Task { [valuesStreamProvider] in
            let stream = valuesStreamProvider()

            for await value in stream {
                if Task.isCancelled { return }
                updateListener(value)
            }
        }

        return Subscription {
            task.cancel()
        }
    }
}

public struct UserDefaultsStorage: Sendable {
    private var userDefaults: UserDefaults {
        _userDefaults()
    }

    private let _userDefaults: @Sendable () -> UserDefaults

    public init(_ userDefaults: @autoclosure @escaping @Sendable () -> UserDefaults) {
        self._userDefaults = userDefaults
    }

    // MARK: - String

    public func getValue(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }

    public func setValue(_ value: String, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<String?> {
        _valuesStream(forKey: key)
    }

    // MARK: - Bool

    public func getValue(forKey key: String) -> Bool? {
        userDefaults.object(forKey: key) != nil ? userDefaults.bool(forKey: key) : nil
    }

    public func setValue(_ value: Bool, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<Bool?> {
        _valuesStream(forKey: key)
    }

    // MARK: - Int

    public func getValue(forKey key: String) -> Int? {
        userDefaults.object(forKey: key) != nil ? userDefaults.integer(forKey: key) : nil
    }

    public func setValue(_ value: Int, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<Int?> {
        _valuesStream(forKey: key)
    }

    // MARK: - Double

    public func getValue(forKey key: String) -> Double? {
        userDefaults.object(forKey: key) != nil ? userDefaults.double(forKey: key) : nil
    }

    public func setValue(_ value: Double, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<Double?> {
        _valuesStream(forKey: key)
    }

    // MARK: - Float

    public func getValue(forKey key: String) -> Float? {
        userDefaults.object(forKey: key) != nil ? userDefaults.float(forKey: key) : nil
    }

    public func setValue(_ value: Float, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<Float?> {
        _valuesStream(forKey: key)
    }

    // MARK: - Data

    public func getValue(forKey key: String) -> Data? {
        userDefaults.data(forKey: key)
    }

    public func setValue(_ value: Data, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<Data?> {
        _valuesStream(forKey: key)
    }

    // MARK: - Date

    public func getValue(forKey key: String) -> Date? {
        userDefaults.object(forKey: key) as? Date
    }

    public func setValue(_ value: Date, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<Date?> {
        _valuesStream(forKey: key)
    }

    // MARK: - URL

    public func getValue(forKey key: String) -> URL? {
        userDefaults.url(forKey: key)
    }

    public func setValue(_ value: URL, forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<URL?> {
        _valuesStream(forKey: key)
    }

    // MARK: - [String]

    public func getValue(forKey key: String) -> [String]? {
        userDefaults.stringArray(forKey: key)
    }

    public func setValue(_ value: [String], forKey key: String) {
        userDefaults.setValue(value, forKey: key)
    }

    public func valuesStream(forKey key: String) -> AsyncStream<[String]?> {
        _valuesStream(forKey: key)
    }

    // MARK: - Removal

    public func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }

    // MARK: - Private API

    private func _valuesStream<Value>(forKey key: String) -> AsyncStream<Value?> where Value: Sendable {
        AsyncStream { continuation in
            let observer = KeyPathObserver(updateListener: { newValue in
                if let newValue = newValue as? Value {
                    continuation.yield(newValue)
                } else {
                    continuation.yield(nil)
                }
            })
            userDefaults.addObserver(observer, forKeyPath: key, options: .new, context: nil)
            continuation.onTermination = { @Sendable _ in
                userDefaults.removeObserver(observer, forKeyPath: key)
            }
        }
    }

    private func _valuesStream(forKey key: String) -> AsyncStream<URL?> {
        AsyncStream { continuation in
            let observer = KeyPathObserver(updateListener: { newValue in
                if
                    let newValue = newValue as? Data,
                    let url = URL(dataRepresentation: newValue, relativeTo: nil)
                {
                    continuation.yield(url)
                } else {
                    continuation.yield(nil)
                }
            })
            userDefaults.addObserver(observer, forKeyPath: key, options: .new, context: nil)
            continuation.onTermination = { @Sendable _ in
                userDefaults.removeObserver(observer, forKeyPath: key)
            }
        }
    }
}

private final class KeyPathObserver: NSObject, Sendable {
    private let updateListener: @Sendable (_ value: Any?) -> Void

    fileprivate init(updateListener: @escaping @Sendable (_ value: Any?) -> Void) {
        self.updateListener = updateListener
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?, context:
        UnsafeMutableRawPointer?
    ) {
        if let change = change, let newValue = change[.newKey] {
            if newValue is NSNull {
                updateListener(nil)
            } else {
                updateListener(newValue)
            }
        }
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

public protocol MutatingThrowingStorage<Key> {
    /// The type of the key used to store values.
    associatedtype Key

    func getValue<Value>(forKey key: Key) throws -> Value?

    mutating func setValue<Value>(_ value: Value, forKey key: Key) throws

    mutating func removeValue(forKey key: Key) throws
}

public protocol Transformer<Input, Output> {
    associatedtype Input
    associatedtype Output

    func transformInput<Input>(_ input: Input) -> Output

    func transformOutput<Output>(_ output: Output) -> Input
}

public protocol ThrowingTransformer<Input, Output> {
    associatedtype Input
    associatedtype Output

    func transformInput(_ input: Input) throws -> Output

    func transformOutput(_ output: Output) throws -> Input
}

public struct JSONTransformer<Input: Codable>: ThrowingTransformer, Sendable {
    public typealias ConfigureEncoder = @Sendable (_ encoder: JSONEncoder) -> Void
    public typealias ConfigureDecoder = @Sendable (_ encoder: JSONDecoder) -> Void

    private let configureEncoder: ConfigureEncoder?
    private let configureDecoder: ConfigureDecoder?

    public init(
        configureEncoder: ConfigureEncoder? = nil,
        configureDecoder: ConfigureDecoder? = nil
    ) {
        self.configureEncoder = configureEncoder
        self.configureDecoder = configureDecoder
    }

    public func transformInput(_ input: Input) throws -> Data {
        let encoder = JSONEncoder()
        configureEncoder?(encoder)
        return try encoder.encode(input)
    }

    public func transformOutput(_ data: Data) throws -> Input {
        let decoder = JSONDecoder()
        configureDecoder?(decoder)
        return try decoder.decode(Input.self, from: data)
    }
}
