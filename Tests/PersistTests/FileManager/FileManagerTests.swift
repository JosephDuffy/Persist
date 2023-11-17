//#if !os(watchOS)
//import XCTest
//@testable import Persist
//
//final class FileManagerTests: XCTestCase {
//
//    var testFilesDirectory: URL {
//        let basePath: URL
//        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, *) {
//            basePath = FileManager.default.temporaryDirectory
//        } else {
//            basePath = Bundle.allBundles.first(where: { $0.bundlePath.hasSuffix(".xctest") })!.bundleURL
//        }
//
//        return basePath.appendingPathComponent("PersistFileManagerTestFiles", isDirectory: true)
//    }
//
//    override func setUpWithError() throws {
//        try FileManager.default.createDirectory(at: testFilesDirectory, withIntermediateDirectories: true, attributes: nil)
//
//        try super.setUpWithError()
//    }
//
//    override func tearDownWithError() throws {
//        try FileManager.default.removeItem(at: testFilesDirectory)
//
//        try super.tearDownWithError()
//    }
//
//    func testPersistedFileManagerAPI() {
//        _ = Persisted(key: testFilesDirectory, storedBy: FileManager.default)
//        _ = Persisted(key: testFilesDirectory, fileManager: .default)
//        _ = Persisted(key: testFilesDirectory, storedBy: FileManager.default, transformer: MockTransformer())
//        _ = Persisted(key: testFilesDirectory, fileManager: .default, transformer: MockTransformer())
//
//        _ = Persisted(key: testFilesDirectory, storedBy: FileManager.default, defaultValue: Data())
//        _ = Persisted(key: testFilesDirectory, fileManager: .default, defaultValue: Data())
//        _ = Persisted(key: testFilesDirectory, storedBy: FileManager.default, transformer: MockTransformer(), defaultValue: Data())
//        _ = Persisted(key: testFilesDirectory, fileManager: .default, transformer: MockTransformer(), defaultValue: Data())
//    }
//
//    func testPersisterFileManagerAPI() {
//        _ = Persister(key: testFilesDirectory, storedBy: FileManager.default)
//        _ = Persister(key: testFilesDirectory, fileManager: .default)
//        _ = Persister(key: testFilesDirectory, storedBy: FileManager.default, transformer: MockTransformer())
//        _ = Persister(key: testFilesDirectory, fileManager: .default, transformer: MockTransformer())
//
//        _ = Persister(key: testFilesDirectory, storedBy: FileManager.default, defaultValue: Data())
//        _ = Persister(key: testFilesDirectory, fileManager: .default, defaultValue: Data())
//        _ = Persister(key: testFilesDirectory, storedBy: FileManager.default, transformer: MockTransformer(), defaultValue: Data())
//        _ = Persister(key: testFilesDirectory, fileManager: .default, transformer: MockTransformer(), defaultValue: Data())
//    }
//
//    func testSettingValue() {
//        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
//
//        addTeardownBlock {
//            try? FileManager.default.removeItem(at: dataURL)
//        }
//
//        let storage = FileManagerStorage()
//        let writtenData = UUID().uuidString.data(using: .utf8)!
//        XCTAssertNoThrow(try storage.storeValue(writtenData, key: dataURL))
//        let readData = try? Data(contentsOf: dataURL)
//        XCTAssertEqual(readData, writtenData)
//    }
//
//    func testReadingExistingFile() throws {
//        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
//
//        addTeardownBlock {
//            try? FileManager.default.removeItem(at: dataURL)
//        }
//
//        let storage = FileManagerStorage()
//        let writtenData = UUID().uuidString.data(using: .utf8)!
//        try writtenData.write(to: dataURL)
//        let readData = storage.retrieveValue(for: dataURL)
//        XCTAssertEqual(readData, writtenData)
//    }
//
//    func testReadingNonExistantFile() throws {
//        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
//        let storage = FileManagerStorage()
//        let readData = storage.retrieveValue(for: dataURL)
//        XCTAssertNil(readData)
//    }
//
//    func testValueBeingPersisted() throws {
//        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
//
//        addTeardownBlock {
//            try? FileManager.default.removeItem(at: dataURL)
//        }
//
//        let storage = FileManagerStorage()
//        let persister = Persister(key: dataURL, storedBy: storage)
//
//        let writtenData = UUID().uuidString.data(using: .utf8)!
//
//        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
//        let subscription = persister.addUpdateListener { result in
//            defer {
//                callsUpdateListenerExpectation.fulfill()
//            }
//
//            switch result {
//            case .success(let update):
//                XCTAssertEqual(update.newValue, writtenData, "Value passed to update listener should be new data when file has been updated on disk")
//            case .failure(let error):
//                XCTFail("Update listener should be notified of a success. Got error: \(error)")
//            }
//        }
//        _ = subscription
//
//        try storage.storeValue(writtenData, key: dataURL)
//
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//
//    func testValueBeingDeleted() throws {
//        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
//
//        addTeardownBlock {
//            try? FileManager.default.removeItem(at: dataURL)
//        }
//
//        let storedData = UUID().uuidString.data(using: .utf8)!
//        let storage = FileManagerStorage()
//        let persister = Persister(key: dataURL, storedBy: storage)
//        try storedData.write(to: dataURL)
//
//        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
//        let subscription = persister.addUpdateListener { result in
//            defer {
//                callsUpdateListenerExpectation.fulfill()
//            }
//
//            switch result {
//            case .success(let update):
//                XCTAssertEqual(update.newValue, .none)
//                XCTAssertEqual(update.event, .removed, "Value passed to update listener should be `.removed` when file has been deleted on disk")
//            case .failure(let error):
//                XCTFail("Update listener should be notified of a success. Got error: \(error)")
//            }
//        }
//        _ = subscription
//
//        try storage.removeValue(for: dataURL)
//
//        waitForExpectations(timeout: 1, handler: nil)
//    }
//
//}
//#endif
