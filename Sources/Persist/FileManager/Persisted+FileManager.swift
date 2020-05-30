import Foundation

extension Persisted where Value == Data {

    public init(
        key: URL,
        defaultValue: Value? = nil,
        storedBy fileManager: FileManager
    ) {
        self.init(key: key, defaultValue: defaultValue, fileManager: fileManager)
    }

    public init(
        key: URL,
        defaultValue: Value? = nil,
        fileManager: FileManager
    ) {
        let persister = Persister(key: key, storedBy: fileManager)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: URL,
        defaultValue: Value? = nil,
        storedBy fileManager: FileManager,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(key: key, defaultValue: defaultValue, fileManager: fileManager, transformer: transformer)
    }

    public init<Transformer: Persist.Transformer>(
        key: URL,
        defaultValue: Value? = nil,
        fileManager: FileManager,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == Data {
        let persister = Persister(key: key, fileManager: fileManager, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}
