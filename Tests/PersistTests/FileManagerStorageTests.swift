#if !os(watchOS)
import XCTest
@testable import Persist

final class FileManagerStorageTests: XCTestCase {

    var testFilesDirectory: URL {
        return testsDirectory.appendingPathComponent("Resources/FileManagerTests", isDirectory: true)
    }

    var testsDirectory: URL {
        return testsBundle.bundleURL
    }

    var testsBundle: Bundle {
        return Bundle.allBundles.first(where: { $0.bundlePath.hasSuffix(".xctest") })!
    }

    override func setUpWithError() throws {
        try FileManager.default.createDirectory(at: testFilesDirectory, withIntermediateDirectories: true, attributes: nil)

        try super.setUpWithError()
    }

    func testSettingValue() {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)

        addTeardownBlock {
            try? FileManager.default.removeItem(at: dataURL)
        }

        let storage = FileManagerStorage()
        let writtenData = UUID().uuidString.data(using: .utf8)!
        XCTAssertNoThrow(try storage.storeValue(writtenData, key: dataURL))
        let readData = try? Data(contentsOf: dataURL)
        XCTAssertEqual(readData, writtenData)
    }

    func testReadingExistingFile() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)

        addTeardownBlock {
            try? FileManager.default.removeItem(at: dataURL)
        }

        let storage = FileManagerStorage()
        let writtenData = UUID().uuidString.data(using: .utf8)!
        try writtenData.write(to: dataURL)
        let readData = try? storage.retrieveValue(for: dataURL)
        XCTAssertEqual(readData, writtenData)
    }

    func testReadingNonExistantFile() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        let storage = FileManagerStorage()
        let readData = try storage.retrieveValue(for: dataURL)
        XCTAssertNil(readData)
    }

    func testValueBeingPersisted() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)

        addTeardownBlock {
            try? FileManager.default.removeItem(at: dataURL)
        }

        let storage = FileManagerStorage()
        let persister = Persister(key: dataURL, storedBy: storage)

        let writtenData = UUID().uuidString.data(using: .utf8)!

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, writtenData, "Value passed to update listener should be new data when file has been updated on disk")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        try storage.storeValue(writtenData, key: dataURL)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testValueBeingDeleted() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)

        addTeardownBlock {
            try? FileManager.default.removeItem(at: dataURL)
        }

        let storedData = UUID().uuidString.data(using: .utf8)!
        let storage = FileManagerStorage()
        let persister = Persister(key: dataURL, storedBy: storage)
        try storedData.write(to: dataURL)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertNil(newValue, "Value passed to update listener should be `nil` when file has been deleted on disk")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        try storage.removeValue(for: dataURL)

        waitForExpectations(timeout: 1, handler: nil)
    }

}
#endif
