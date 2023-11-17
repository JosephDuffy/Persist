import Foundation
#if canImport(Combine)
import Combine
#endif

extension Persister.Update.Event: Hashable where Value: Hashable {}
extension Persister.Update.Event: Equatable where Value: Equatable {}
extension Persister.Update: Hashable where Value: Hashable {}
extension Persister.Update: Equatable where Value: Equatable {}

/**
 An object that can store and retrieve values from a `Storage` instance, optionally passing values through a
 transformer.
 */
public final class Persister<Value, Storage: Persist.Storage> where Storage.Value == Value {
    /// An update that was performed by a persister.
    public struct Update {
        /// Create and return a new `Update` for a persisted value.
        ///
        /// - Parameter persistedValue: The value that was persisted.
        /// - Returns: The created `Update`.
        public static func persisted(_ persistedValue: Value) -> Update {
            return Update(newValue: persistedValue, event: .persisted(persistedValue))
        }

        /// Create and return a new `Update` for a removed value.
        ///
        /// - Parameter defaultValue: The default value that will be falled back to.
        /// - Returns: The created `Update`.
        public static func removed(defaultValue: Value) -> Update {
            return Update(newValue: defaultValue, event: .removed)
        }

        /// An event that triggers an update.
        public enum Event {
            /// The was persisted.
            case persisted(Value)

            /// The value was removed.
            case removed

            /// The value after the update. `nil` indicates the value was removed.
            public var value: Value? {
                switch self {
                case .persisted(let value):
                    return value
                case .removed:
                    return nil
                }
            }
        }

        /// The new value, after the update. If the value was removed this will be the default value.
        public let newValue: Value

        /// The event that triggered the update.
        public let event: Event

        private init(newValue: Value, event: Event) {
            self.newValue = newValue
            self.event = event
        }
    }

    /// The payload that will be passed to an update listener.
    public typealias UpdatePayload = Result<Update, Error>

    /// A closure that will be called when an update occurs.
    public typealias UpdateListener = (UpdatePayload) -> Void

    /// A closure that can add an update listener.
    public typealias AddUpdateListener = (_ updateListener: @escaping UpdateListener, _ defaultValueGetter: @escaping () -> Value) -> AnyCancellable

    #if canImport(Combine)
    /// A publisher that will publish updates as they occur.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var updatesPublisher: AnyPublisher<UpdatePayload, Never> {
        return updatesSubject.eraseToAnyPublisher()
    }

    /// A publisher that will publish updates as they occur.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var publisher: AnyPublisher<Value, Never> {
        return subject.eraseToAnyPublisher()
    }
    #endif

    /// The default value that will be returned when a value has been be persisted or an error occurs.
    public lazy var defaultValue: Value = {
        return _defaultValue()
    }()

    private var defaultValueLock = NSLock()

    /// An option set that describes when to persist the default value.
    public var defaultValuePersistBehaviour: DefaultValuePersistOption

    private let key: Storage.Key

    private let storage: Storage

    private let _defaultValue: () -> Value

    /// The cancellable object that encapsulates updates from the storage.
    private var storageUpdateListenerCancellable: AnyCancellable?

    /// A collection of the update listeners that will be notified when a value changes. The key (a `UUID`)
    /// is not exposed, but rather captured by the `Subscription` that the caller retains.
    private var updateListeners: [UUID: UpdateListener] = [:]

    /// A lock used to protect access to ``updateListeners``.
    private let updateListenersLock = NSLock()

    #if canImport(Combine)
    /// The updates subject that publishes updates.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private let updatesSubject = PassthroughSubject<UpdatePayload, Never>()

    /// The updates subject that publishes updates.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private lazy var subject = CurrentValueSubject<Value, Never>(self.retrieveValue())
    #endif

    // MARK: - Storage.Value == Value

    /**
     Create a new instance that stores the value against the `key` using `storage`, defaulting to
     `defaultValue`.

     - parameter key: The key to store the value against
     - parameter storage: The storage to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.key = key
        self.storage = storage
        _defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        subscribeToStorageUpdates { updateListener, defaultValueGetter in
            storage.addUpdateListener(forKey: key) { newValue in
                guard let value = newValue else {
                    updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                    return
                }

                updateListener(.success(.persisted(value)))
            }
        }
    }

    public init<WrappedValue>(
        key: Storage.Key,
        storedBy storage: Storage,
        defaultValue: @autoclosure @escaping () -> WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue? {
        self.key = key
        self.storage = storage
        _defaultValue = defaultValue
        self.defaultValuePersistBehaviour = defaultValuePersistBehaviour

        subscribeToStorageUpdates { updateListener, defaultValueGetter in
            storage.addUpdateListener(forKey: key) { newValue in
                guard let value = newValue else {
                    updateListener(.success(.removed(defaultValue: defaultValueGetter())))
                    return
                }

                updateListener(.success(.persisted(value)))
            }
        }
    }

    @_disfavoredOverload
    public convenience init<AnyStorage: Persist.Storage>(
        key: Storage.Key,
        storedBy storage: AnyStorage,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where AnyStorage.Key == Storage.Key, AnyStorage.Value == Any, Storage == TransformedStorage<AnyStorage.Key, Value> {
        let transformer = ClosureTransformer<Value, Any>(
            inputClosure: { $0 as Any },
            outputClosure: { output -> Value in
                output as! Value
            }
        )
        let transformedStorage = TransformedStorage(
            transformer: transformer,
            storage: storage
        )
        self.init(
            key: key,
            storedBy: transformedStorage,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<WrappedStorage: Persist.Storage>(
        key: WrappedStorage.Key,
        storedBy storage: WrappedStorage,
        transformer: any Transformer<Value, WrappedStorage.Value>,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where WrappedStorage.Key == Storage.Key, Storage == TransformedStorage<WrappedStorage.Key, Value> {
        let transformedStorage = TransformedStorage<WrappedStorage.Key, Value>(
            transformer: transformer,
            storage: storage
        )
        self.init(
            key: key,
            storedBy: transformedStorage,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<WrappedValue, WrappedStorage: Persist.Storage>(
        key: WrappedStorage.Key,
        storedBy storage: WrappedStorage,
        transformer: any Transformer<Value, WrappedStorage.Value>,
        defaultValue: @autoclosure @escaping () -> WrappedValue? = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, WrappedStorage.Key == Storage.Key, Storage == TransformedStorage<WrappedStorage.Key, Value> {
        let transformedStorage = TransformedStorage<WrappedStorage.Key, Value>(
            transformer: transformer,
            storage: storage
        )
        self.init(
            key: key,
            storedBy: transformedStorage,
            defaultValue: defaultValue(),
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    // MARK: - Functions

    /**
     Persist the provided value.

     - throws: Any errors thrown by the storage.
     */
    public func persist(_ newValue: Value) throws {
        try storage.storeValue(newValue, key: key)
    }

    /**
     Attempts to retrieve the value from the storage. If the value is `nil` or an error occurs when retrieving
     the value the default value will be returned.

     If the `persistWhenNil` option has been provided and the storage returns `nil` the default value
     will be persisted.

     If the `persistOnError` option has been provided and there is an error retrieving the value the default
     value will be persisted.

     - returns: The persisted value, or the default value if no value has been persisted or an error occurs.
     */
    public func retrieveValue() -> Value {
        do {
            return try retrieveValueOrThrow()
        } catch {
            defaultValueLock.lock()
            let defaultValue = self.defaultValue
            if defaultValuePersistBehaviour.contains(.persistOnError) {
                try? persist(defaultValue)
            }
            defaultValueLock.unlock()

            return defaultValue
        }
    }

    /**
     Attempts to retrieve the value from the storage. If the value is `nil` the default value will be returned.

     If the `persistWhenNil` option has been provided and the storage returns `nil` the default value
     will be persisted.

     If the `persistOnError` option has been provided and there is an error retrieving the value the default
    value will **not** be persisted and the error will be thrown.

     - throws: Any error thrown while retrieving the value.
     - returns: The persisted value, or the default value if no value has been persisted.
     */
    public func retrieveValueOrThrow() throws -> Value {
        if let retrieveValue = try storage.retrieveValue(for: key) {
            return retrieveValue
        }

        defaultValueLock.lock()
        let defaultValue = self.defaultValue
        if defaultValuePersistBehaviour.contains(.persistWhenNil) {
            try? persist(defaultValue)
        }
        defaultValueLock.unlock()

        return defaultValue
    }

    /**
     Remove the value.

     - throws: Any errors thrown by the storage.
     */
    public func removeValue() throws {
        try storage.removeValue(for: key)
    }

    /**
     Add a closure that will be called when the storage notifies the persister of an update.

     - parameter updateListener: The closure to call when an update occurs.
     - returns: An object that represents the closure's subscription to changes. This object must be retained by the caller.
     */
    public func addUpdateListener(_ updateListener: @escaping UpdateListener) -> AnyCancellable {
        let uuid = UUID()
        updateListenersLock.lock()
        updateListeners[uuid] = updateListener
        updateListenersLock.unlock()

        return Subscription { [weak self] in
            guard let self = self else { return }
            self.updateListenersLock.lock()
            self.updateListeners.removeValue(forKey: uuid)
            self.updateListenersLock.unlock()
        }.eraseToAnyCancellable()
    }

    private func notifyUpdateListenersOfResult(_ result: UpdatePayload) {
        updateListenersLock.lock()
        // Take a copy of the update listeners so the lock can be unlocked when
        // the closures are called, preventing a deadlock if a subscriber adds
        // a new subscription is response to an update.
        let updateListeners = self.updateListeners.values
        updateListenersLock.unlock()

        updateListeners.forEach { $0(result) }

        #if canImport(Combine)
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            updatesSubject.send(result)

            switch result {
            case .success(let update):
                subject.send(update.newValue)
            case .failure:
                break
            }
        }
        #endif
    }

    private func subscribeToStorageUpdates(addUpdateListener: AddUpdateListener) {
        storageUpdateListenerCancellable = addUpdateListener(
            { [weak self] result in
                self?.notifyUpdateListenersOfResult(result)
            },
            { [unowned self] in
                // TODO: Honour `defaultValuePersistBehaviour`
                self.defaultValueLock.lock()
                let defaultValue = self.defaultValue
                self.defaultValueLock.unlock()
                return defaultValue
            }
        )
    }

}
