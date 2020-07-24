#if !os(watchOS)
import XCTest
import Persist

final class PersistedFileManagerTests: XCTestCase {
    
    var testFilesDirectory: URL {
        let basePath: URL
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, *) {
            basePath = FileManager.default.temporaryDirectory
        } else {
            basePath = Bundle.allBundles.first(where: { $0.bundlePath.hasSuffix(".xctest") })!.bundleURL
        }
        
        return basePath.appendingPathComponent("PersistPersisterFileManagerTestFiles", isDirectory: true)
    }
    
    override func setUpWithError() throws {
        try FileManager.default.createDirectory(at: testFilesDirectory, withIntermediateDirectories: true, attributes: nil)
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: testFilesDirectory)
        
        try super.tearDownWithError()
    }
    
    func testValue_storedByInitialiser() throws {
        let defaultValue = Data("default".utf8)
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted(key: dataURL, storedBy: FileManager.default, defaultValue: defaultValue)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssert(persisted.wrappedValue == defaultValue, "Should return default value")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValue_fileManagerInitialiser() throws {
        let defaultValue = Data("default".utf8)
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted(key: dataURL, fileManager: FileManager.default, defaultValue: defaultValue)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssert(persisted.wrappedValue == defaultValue, "Should return default value")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValueWithTransformer_storedByInitialiser() throws {
        let defaultValue = Data("default".utf8)
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted(key: dataURL, storedBy: FileManager.default, transformer: MockTransformer(), defaultValue: defaultValue)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssert(persisted.wrappedValue == defaultValue, "Should return default value")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testValueWithTransformer_fileManagerInitialiser() throws {
        let defaultValue = Data("default".utf8)
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted(key: dataURL, fileManager: FileManager.default, transformer: MockTransformer(), defaultValue: defaultValue)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssert(persisted.wrappedValue == defaultValue, "Should return default value")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOptionalValue_storedByInitialiser() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted<Data?>(key: dataURL, storedBy: FileManager.default)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssertNil(persisted.wrappedValue, "Default value should be `nil`")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOptionalValue_fileManagerInitialiser() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted<Data?>(key: dataURL, fileManager: FileManager.default)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssertNil(persisted.wrappedValue, "Default value should be `nil`")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOptionalValueWithDefault_storedByInitialiser() throws {
        let defaultValue = Data("default".utf8)
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted<Data?>(key: dataURL, storedBy: FileManager.default, defaultValue: defaultValue)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssert(persisted.wrappedValue == defaultValue, "Default value should be passed default value")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOptionalValueWithDefault_fileManagerInitialiser() throws {
        let defaultValue = Data("default".utf8)
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted<Data?>(key: dataURL, fileManager: FileManager.default, defaultValue: defaultValue)
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssert(persisted.wrappedValue == defaultValue, "Default value should be passed default value")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOptionalValueWithTransformer_storedByInitialiser() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted<Data?>(key: dataURL, storedBy: FileManager.default, transformer: MockTransformer())
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssertNil(persisted.wrappedValue, "Default value should be `nil`")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOptionalValueWithTransformer_fileManagerInitialiser() throws {
        let dataURL = testFilesDirectory.appendingPathComponent("\(UUID().uuidString).data", isDirectory: false)
        var persisted = Persisted<Data?>(key: dataURL, fileManager: FileManager.default, transformer: MockTransformer())
        let storedValue = Data("stored-value".utf8)
        
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }
            
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription
        
        XCTAssertNil(persisted.wrappedValue, "Default value should be `nil`")
        persisted.wrappedValue = storedValue
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
#endif
