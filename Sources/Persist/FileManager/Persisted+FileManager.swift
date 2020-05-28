import Foundation

extension Persisted where Value == Data {

    public init(
        key: URL,
        defaultValue: Value? = nil,
        storedBy fileManager: FileManager
    ) {
        let persister = Persister(key: key, storedBy: fileManager)
        self.init(persister: persister, defaultValue: defaultValue)
    }

    public init(
        key: URL,
        defaultValue: Value? = nil,
        fileManager: FileManager
    ) {
        self.init(persister: Persister(key: key, fileManager: fileManager), defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: URL,
        defaultValue: Value? = nil,
        storedBy fileManager: FileManager,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == Data {
        let persister = Persister(key: key, storedBy: fileManager, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
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
