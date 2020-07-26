import Foundation

/**
 A `Storage` wrapper around `FileManager`.
 */
internal final class FileManagerStorage: Storage {

    /// The value type the `FileManagerStorage` can store.
    internal typealias Value = Data

    /// Returns the default singleton instance.
    internal private(set) static var `default` = FileManagerStorage(fileManager: .default)

    private let fileManager: FileManager

    private var updateListeners: [URL: [UUID: UpdateListener]] = [:]

    /**
     Create a new `FileManagerStorage` wrapper around the provided `FileManager`.

     - Note: The `FileManager` is not used to write the data to disk.
     - parameter fileManager: The file manager to use for storage. Defaults to `default`.
     */
    internal init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    /**
     Store the provided data at the provided file URL.

     - Note: The `FileManager` is not used to write the data to disk.
     - parameter data: The data to store.
     - parameter url: The URL of the file to save the data to. Must be a file URL.
     */
    internal func storeValue(_ data: Data, key url: URL) throws {
        try data.write(to: url)

        updateListeners[url]?.values.forEach { $0(data) }
    }

    /**
     Delete the file at the provided URL.

     - parameter url: The URL of the file to delete.
     */
    internal func removeValue(for url: URL) throws {
        try fileManager.removeItem(at: url)

        updateListeners[url]?.values.forEach { $0(nil) }
    }

    /**
     Returns the contents of the file at the specified URL.

     - parameter url: The URL of the file whose content will be returned.
     - returns: The contents of the file, or `nil` if the URL is a directory or an error occurs.
     */
    internal func retrieveValue(for url: URL) -> Data? {
        return fileManager.contents(atPath: url.path)
    }

    /**
     Add a closure that will be called when the file at the provided URL is updated.

     - Important: The closure will **only** be called if the file is updated by this instance of the `FileManagerStorage`.
     - parameter url: The URL to monitor.
     - parameter updateListener: The closure to call when the file changes.
     - returns: An object that represents the subscription and can be used to cancel further updates.
     */
    internal func addUpdateListener(forKey url: URL, updateListener: @escaping UpdateListener) -> AnyCancellable {
        let uuid = UUID()

        updateListeners[url, default: [:]][uuid] = updateListener

        return Subscription { [weak self] in
            self?.updateListeners[url]?.removeValue(forKey: uuid)
        }.eraseToAnyCancellable()
    }

}
