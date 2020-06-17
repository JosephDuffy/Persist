import Foundation

extension Persister where Value == Data {

    public convenience init(
        key: URL,
        storedBy fileManager: FileManager,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            fileManager: fileManager,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init(
        key: URL,
        fileManager: FileManager,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }
}

extension Persister where Value == Data? {

    public convenience init(
        key: URL,
        storedBy fileManager: FileManager,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            fileManager: fileManager,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init(
        key: URL,
        fileManager: FileManager,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager),
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }
}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(
            key: key,
            fileManager: fileManager,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager),
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        self.init(
            key: key,
            fileManager: fileManager,
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

    public convenience init<Transformer: Persist.Transformer, WrappedValue>(
        key: URL,
        fileManager: FileManager,
        transformer: Transformer,
        defaultValue: Value = nil,
        defaultValuePersistBehaviour: DefaultValuePersistOption = []
    ) where Value == WrappedValue?, Transformer.Input == WrappedValue, Transformer.Output == Data {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager),
            transformer: transformer,
            defaultValue: defaultValue,
            defaultValuePersistBehaviour: defaultValuePersistBehaviour
        )
    }

}
