import Foundation

extension Persister where Value == Data {

    public convenience init(
        key: URL,
        storedBy fileManager: FileManager
    ) {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager)
        )
    }

    public convenience init(
        key: URL,
        fileManager: FileManager
    ) {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager)
        )
    }
}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: URL,
        storedBy fileManager: FileManager,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager),
            transformer: transformer
        )
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: URL,
        fileManager: FileManager,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == Data {
        self.init(
            key: key,
            storedBy: FileManagerStorage(fileManager: fileManager),
            transformer: transformer
        )
    }

}
