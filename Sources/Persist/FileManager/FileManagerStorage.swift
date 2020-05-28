import Foundation

public final class FileManagerStorage: Storage {

    public typealias Value = Data

    private let fileManager: FileManager

    private var updateListeners: [URL: [UUID: UpdateListener]] = [:]

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func storeValue(_ data: Data, key url: URL) throws {
        try data.write(to: url)

        updateListeners[url]?.values.forEach { $0(data) }
    }

    public func removeValue(for url: URL) throws {
        try fileManager.removeItem(at: url)

        updateListeners[url]?.values.forEach { $0(nil) }
    }

    public func retrieveValue(for url: URL) -> Data? {
        return fileManager.contents(atPath: url.path)
    }

    public func addUpdateListener(forKey url: URL, updateListener: @escaping UpdateListener) -> Cancellable {
        let uuid = UUID()

        updateListeners[url, default: [:]][uuid] = updateListener

        return Cancellable { [weak self] in
            self?.updateListeners[url]?.removeValue(forKey: uuid)
        }
    }

}
