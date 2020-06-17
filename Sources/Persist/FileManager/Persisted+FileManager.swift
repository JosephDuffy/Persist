import Foundation

extension Persisted where Value == Data {

    public init(
        key: URL,
        storedBy fileManager: FileManager,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, fileManager: fileManager, defaultValue: defaultValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    public init(
        key: URL,
        fileManager: FileManager,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, storedBy: FileManagerStorage(fileManager: fileManager), defaultValue: defaultValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

}

extension Persisted where Value == Data? {

    public init(
        key: URL,
        storedBy fileManager: FileManager,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(key: key, fileManager: fileManager, defaultValue: defaultValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    public init(
        key: URL,
        fileManager: FileManager,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        let persister = Persister(key: key, storedBy: fileManager, defaultValue: defaultValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
        self.init(persister: persister)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(key: key, fileManager: fileManager, transformer: transformer, defaultValue: defaultValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    public init<Transformer: Persist.Transformer>(
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        let persister = Persister(key: key, fileManager: fileManager, transformer: transformer, defaultValue: defaultValue)
        self.init(persister: persister)
    }

    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        self.init(key: key, fileManager: fileManager, transformer: transformer, defaultValue: defaultValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
    }

    public init<Transformer: Persist.Transformer, WrappedValue>(
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        let persister = Persister(key: key, storedBy: FileManagerStorage(fileManager: fileManager), transformer: transformer, defaultValue: defaultValue, defaultValuePersistBehaviour: defaultValuePersistBehaviour)
        self.init(persister: persister)
    }

}
