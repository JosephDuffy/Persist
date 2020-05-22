import Foundation

extension FileManager: Storage {

    public func storeValue(_ data: Data, key url: URL) throws {
        try data.write(to: url)
    }

    public func removeValue(for url: URL) throws {
        try removeItem(at: url)
    }

    public func retrieveValue(for url: URL) throws -> Data? {
        return try Data(contentsOf: url)
    }

    public func addUpdateListener(forKey url: URL, updateListener: @escaping UpdateListener) -> Cancellable {
        let folderMonitorQueue = DispatchQueue(label: "FileManagerStorage")
        let monitoredFolderFileDescriptor = open(url.path, O_EVTONLY)

        let folderMonitorSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: monitoredFolderFileDescriptor,
            // TODO: Listen for deletes, or detect in event handler
            eventMask: .write,
            queue: folderMonitorQueue
        )
        folderMonitorSource.setEventHandler { [weak self] in
            guard let self = self else { return }
            // TODO: Handle errors
            guard let data = try? self.retrieveValue(for: url) else { return }
            updateListener(data)
        }
        return Cancellable {
            folderMonitorSource.cancel()
        }
    }

}
