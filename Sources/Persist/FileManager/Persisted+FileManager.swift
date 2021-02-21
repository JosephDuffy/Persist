import Foundation
import PersistCore

extension Persisted where Value == Data {

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: URL,
        storedBy fileManager: FileManager,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, fileManager: fileManager, defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        wrappedValue: Value,
        key: URL,
        storedBy fileManager: FileManager,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, fileManager: fileManager, defaultValue: wrappedValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: URL,
        fileManager: FileManager,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, storedBy: FileManagerStorage(fileManager: fileManager), defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        wrappedValue: Value,
        key: URL,
        fileManager: FileManager,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, storedBy: FileManagerStorage(fileManager: fileManager), defaultValue: wrappedValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

}

extension Persisted where Value == Data? {

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: URL,
        storedBy fileManager: FileManager,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, fileManager: fileManager, defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        wrappedValue: Value,
        key: URL,
        storedBy fileManager: FileManager,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, fileManager: fileManager, defaultValue: wrappedValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        key: URL,
        fileManager: FileManager,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        let persister = Persister(key: key, storedBy: fileManager, defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour)
        self.init(persister: persister)
    }

    /**
     Create a new instance that stores the value against the `key`, storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init(
        wrappedValue: Value,
        key: URL,
        fileManager: FileManager,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        let persister = Persister(key: key, storedBy: fileManager, defaultValue: wrappedValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
        self.init(persister: persister)
    }

}

extension Persisted {

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(key: key, fileManager: fileManager, transformer: transformer, defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        wrappedValue: Value,
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(key: key, fileManager: fileManager, transformer: transformer, defaultValue: wrappedValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        let persister = Persister(key: key, fileManager: fileManager, transformer: transformer, defaultValue: defaultValue())
        self.init(persister: persister)
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer>(
        wrappedValue: Value,
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        let persister = Persister(key: key, fileManager: fileManager, transformer: transformer, defaultValue: wrappedValue)
        self.init(persister: persister)
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        self.init(key: key, fileManager: fileManager, transformer: transformer, defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        wrappedValue: Value,
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        self.init(key: key, fileManager: fileManager, transformer: transformer, defaultValue: wrappedValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `defaultValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. Defaults to `nil`.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValue: @autoclosure @escaping () -> Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        let persister = Persister(key: key, storedBy: FileManagerStorage(fileManager: fileManager), transformer: transformer, defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour)
        self.init(persister: persister)
    }

    /**
     Create a new instance that stores the value against the `key`,  storing values using the specified
     `FileManager`, defaulting to `wrappedValue`.

     Values stored will be processed by the provided transformer before being persisted and after being
     retrieved from the storage.

     - parameter wrappedValue: The value to use when a value has not yet been stored, or an error occurs.
     - parameter key: The key to store the value against
     - parameter fileManager: The file manager to use to persist and retrieve the value.
     - parameter transformer: A transformer to transform the value before being persisted and after being retrieved from the storage
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     */
    public init<Transformer: Persist.Transformer, WrappedValue>(
        wrappedValue: Value,
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        let persister = Persister(key: key, storedBy: FileManagerStorage(fileManager: fileManager), transformer: transformer, defaultValue: wrappedValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
        self.init(persister: persister)
    }

}
