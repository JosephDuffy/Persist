import Foundation

public final class FileManagerStorage: Storage {

    public typealias Value = Data

    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func storeValue(_ data: Data, key url: URL) throws {
        try data.write(to: url)
    }

    public func removeValue(for url: URL) throws {
        try fileManager.removeItem(at: url)
    }

    public func retrieveValue(for url: URL) throws -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            if (error as NSError).code == 260 {
                return nil
            } else {
                throw error
            }
        }
    }

    enum FileWatcherError: LocalizedError {
        case directoryOpenFailed(Int32)
        case directoryURLInvalid(URL)

        var errorDescription: String? {
            switch self {
            case .directoryOpenFailed(let errno):
                return String(cString: strerror(errno))
            case .directoryURLInvalid(let url):
                return "URL is invalid: \(url)"
            }
        }
    }

    public func addUpdateListener(forKey url: URL, updateListener: @escaping UpdateListener) -> Cancellable {
        guard url.isFileURL else {
            print("Not a file URL")
            // TODO: Call update listener
            return Cancellable {}
        }

        let isDirectory: Bool

        if #available(macOS 10.11, iOS 9.0, *) {
            isDirectory = url.hasDirectoryPath
        } else {
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            if let type = attributes?[FileAttributeKey.type] as? FileAttributeType {
                isDirectory = type == .typeDirectory
            } else {
                // TODO: Call update listener
                return Cancellable { }
            }
        }

        guard !isDirectory else {
            print("URL is a directory", url)
            // TODO: Call update listener
            return Cancellable { }
        }

        let cancellable = FileManagerUpdateListenerCancellable()

        let dispatchQueue = DispatchQueue(label: "FileManagerStorage")
        var lastFileState: Date?

        /**
         Read the file. Returns `true` if the file exists and was successful read, `false` if there was an error, if `nil` if the file has not been modified.
         */
        func readFile() -> Bool? {
            do {
                // This may seem unneccessary (and it probably is) but removing it and checking for the error
                // thrown by `attributesOfItem` (code 260) causes multiple calls to the completion handler
                _ = try FileHandle(forReadingFrom: url)

                guard let newFileData = try fileManager.attributesOfItem(atPath: url.path)[FileAttributeKey.modificationDate] as? Date else {
                    return false
                }

                if newFileData.description != lastFileState?.description {
                    lastFileState = newFileData
                } else {
                    return nil
                }

                guard let data = try self.retrieveValue(for: url) else { return false }
                updateListener(data)
                return true
            } catch {
//                if (error as NSError).code == 260, (error as NSError).domain == NSCocoaErrorDomain {
                if (error as NSError).code == CocoaError.fileNoSuchFile.rawValue, (error as NSError).domain == NSCocoaErrorDomain {
                    // File doesn't exist
                    if lastFileState != nil {
                        lastFileState = nil
                        updateListener(nil)
                        return false
                    } else {
                        return nil
                    }
                } else {
                    print("Read error", error)
                    return false
                }
            }
        }

        do {
            let fileWatcher = try FileWatcher(directoryURL: url, dispatchQueue: dispatchQueue) {
                // The file has changed
                if readFile() == false {
                    // TODO: Cancel file watcher and enable directory watcher
                }
            }
            cancellable.fileWatcher = fileWatcher

            do {
                lastFileState = try fileManager.attributesOfItem(atPath: url.path)[FileAttributeKey.modificationDate] as? Date
            } catch {
                print("Error getting attributed", error)
            }
        } catch FileWatcher.FileWatcherError.fileOpenFailed(2) {
            // File does not exist
            print("File", url, "doesn't exist; falling back to directory watcher", String(cString: strerror(2)))
            do {
                let directory = url.deletingLastPathComponent()
                print("Watching directory", directory)
                let directoryWatcher = try DirectoryWatcher(directoryURL: directory, dispatchQueue: dispatchQueue, updateListener: {
                    print("Something in the directory changed")

                    if readFile() == true {
                        // TODO: Cancel directory watcher and enable file watcher
                    }
                })
                cancellable.directoryWatcher = directoryWatcher
            } catch {
                return Cancellable { }
            }
        } catch {
            print("Another error occured", error)
            // Some other error
            return Cancellable { }
        }

        return cancellable
    }

}

private final class FileManagerUpdateListenerCancellable: Cancellable {

    fileprivate var fileWatcher: FileWatcher?

    fileprivate var directoryWatcher: DirectoryWatcher?

    fileprivate var fileHandle: FileHandle?

    fileprivate var readSource: DispatchSourceRead?

    fileprivate var notificationObserver: NSObjectProtocol?

    required init() {
        super.init { }
    }

    override func cancel() {
        super.cancel()

        fileWatcher?.cleanup()
        directoryWatcher?.cleanup()
        fileHandle?.closeFile()
    }

}

private final class FileWatcher {

    typealias UpdateListener = () -> Void

    enum FileWatcherError: LocalizedError {
        case fileOpenFailed(Int32)
        case fileURLInvalid(URL)

        var errorDescription: String? {
            switch self {
            case .fileOpenFailed(let errno):
                return String(cString: strerror(errno))
            case .fileURLInvalid(let url):
                return "URL is invalid: \(url)"
            }
        }
    }

    private let fileDescriptor: Int32

    private let folderMonitorSource: DispatchSourceFileSystemObject

    init(directoryURL url: URL, dispatchQueue: DispatchQueue, updateListener: @escaping UpdateListener) throws {
        fileDescriptor = try url.withUnsafeFileSystemRepresentation { path in
            guard let path = path else { throw FileWatcherError.fileURLInvalid(url) }

            let result = open(path, O_EVTONLY)

            guard result >= 0 else { throw FileWatcherError.fileOpenFailed(errno) }

            return result
        }

        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: dispatchQueue
        )
        folderMonitorSource.setCancelHandler { [weak self] in
            self?.cleanup()
        }
        folderMonitorSource.setEventHandler {
            updateListener()
        }

        folderMonitorSource.resume()
    }

    deinit {
        cleanup()
    }

    func makeCancellable() -> Cancellable {
        return Cancellable {
            self.cleanup()
        }
    }

    func cleanup() {
        close(fileDescriptor)
    }

}

private final class DirectoryWatcher {

    typealias UpdateListener = () -> Void

    enum DirectoryWatcherError: LocalizedError {
        case directoryOpenFailed(Int32)
        case directoryURLInvalid(URL)

        var errorDescription: String? {
            switch self {
            case .directoryOpenFailed(let errno):
                return String(cString: strerror(errno))
            case .directoryURLInvalid(let url):
                return "URL is invalid: \(url)"
            }
        }
    }

    private let fileDescriptor: Int32

    private let folderMonitorSource: DispatchSourceFileSystemObject

    init(directoryURL url: URL, dispatchQueue: DispatchQueue, updateListener: @escaping UpdateListener) throws {
        fileDescriptor = try url.withUnsafeFileSystemRepresentation { path in
            guard let path = path else { throw DirectoryWatcherError.directoryURLInvalid(url) }

            let result = open(path, O_EVTONLY)

            guard result >= 0 else { throw DirectoryWatcherError.directoryOpenFailed(errno) }

            return result
        }

        folderMonitorSource = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: dispatchQueue
        )
        folderMonitorSource.setCancelHandler { [weak self] in
            self?.cleanup()
        }
        folderMonitorSource.setEventHandler {
            updateListener()
        }

        folderMonitorSource.resume()
    }

    deinit {
        cleanup()
    }

    func makeCancellable() -> Cancellable {
        return Cancellable {
            self.cleanup()
        }
    }

    func cleanup() {
        close(fileDescriptor)
    }

}
