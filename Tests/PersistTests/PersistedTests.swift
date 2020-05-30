#if !os(watchOS)
import XCTest
@testable import Persist

final class PersistedTests: XCTestCase {

    func testAnyAPI() {
        _ = Persisted<String>(key: "test-key", storedBy: InMemoryStorage<Any>())
    }

    func testAnyAPIWithTransformer() {
        struct StoredValue: Codable, Equatable {
            let property: String
        }

        _ = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage<Any>(), transformer: JSONTransformer())
    }

    func testWithTransformer() {
        struct StoredValue: Codable, Equatable {
            let property: String
        }

        let storage = InMemoryStorage<Data>()
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: storage, transformer: JSONTransformer())
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = storedValue
        XCTAssertEqual(persisted.wrappedValue, storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSettingWrappedValue() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage())
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = storedValue
        XCTAssertEqual(persisted.wrappedValue, storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSettingWrappedValueToNil() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage())
        let storedValue = StoredValue(property: "value")
        persisted.wrappedValue = storedValue

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertNil(newValue, "Value passed to update listener should be nil to indicate delete")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = nil

        XCTAssertNil(persisted.wrappedValue, "Should return nil when value has been deleted")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSettingWrappedValueToNilWithTransformer() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage(), transformer: JSONTransformer())
        let storedValue = StoredValue(property: "value")
        persisted.wrappedValue = storedValue

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertNil(newValue, "Value passed to update listener should be nil to indicate delete")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = nil

        XCTAssertNil(persisted.wrappedValue, "Should return nil when value has been deleted")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnyStorageSettingWithDifferentStoredValueType() throws {
        let key = "key"
        let actualValue = "test"
        let storage = InMemoryStorage<Any>()
        let persister = Persister<Int>(key: key, storedBy: storage)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener() { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int.self)
            default:
                XCTFail()
            }
        }
        _ = cancellable

        storage.storeValue(actualValue, key: "key")

        XCTAssertThrowsError(try persister.retrieveValue(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int.self)
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1)
    }

    func testAnyStorageSettingWithDifferentStoredValueTypeAndTransformerOutput() throws {
        let key = "key"
        let actualValue = "test"
        let storage = InMemoryStorage<Any>()
        let persister = Persister<Int>(key: key, storedBy: storage, transformer: JSONTransformer())

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener() { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Data.self)
            default:
                XCTFail()
            }
        }
        _ = cancellable

        storage.storeValue(actualValue, key: "key")

        XCTAssertThrowsError(try persister.retrieveValue(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Data.self)
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1)
    }

    func testAnyStorageSettingToValueDifferentFromTransformerOutput() {
        let key = "key"
        let actualValue = "test"
        let storage = InMemoryStorage<Any>()
        let transformer = MockTransformer<Int>()
        let persister = Persister<Int>(key: key, storedBy: storage, transformer: transformer)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener() { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int.self)
            default:
                XCTFail()
            }
        }
        _ = cancellable

        storage.storeValue(actualValue, key: key)

        XCTAssertThrowsError(try persister.retrieveValue(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int.self)
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1)
    }

    func testAnyStorageSettingWithTransformerError() {
        let key = "key"
        let actualValue = "test"
        let storage = InMemoryStorage<Any>()
        let transformer = MockTransformer<String>()
        let transformerError = NSError(domain: "persist-tests-domain", code: 1, userInfo: nil)
        let persister = Persister<String>(key: key, storedBy: storage, transformer: transformer)

        transformer.errorToThrow = transformerError

        XCTAssertThrowsError(try persister.persist(actualValue), "Setting a value when the transformer throws should throw") { error in
            XCTAssertEqual(error as NSError, transformerError, "Should throw error thrown by transformer")
        }
    }

    func testAnyStorageRetievingWithTransformerError() throws {
        let key = "key"
        let storedValue = "test"
        let storage = InMemoryStorage<Any>()
        let transformer = MockTransformer<String>()
        let transformerError = NSError(domain: "persist-tests-domain", code: 1, userInfo: nil)
        let persister = Persister<String>(key: key, storedBy: storage, transformer: transformer)

        try persister.persist(storedValue)
        transformer.errorToThrow = transformerError

        XCTAssertThrowsError(try persister.retrieveValue(), "Retrieving a value when the transformer throws should throw") { error in
            XCTAssertEqual(error as NSError, transformerError, "Should throw error thrown by transformer")
        }
    }

    func testAnyStorageUpdateListenerTransformerError() {
        let key = "key"
        let storedValue = "test"
        let storage = InMemoryStorage<Any>()
        let transformer = MockTransformer<String>()
        let transformerError = NSError(domain: "persist-tests-domain", code: 1, userInfo: nil)
        let persister = Persister<String>(key: key, storedBy: storage, transformer: transformer)
        transformer.errorToThrow = transformerError

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener() { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .failure(let error):
                XCTAssertEqual(error as NSError, transformerError, "Should pass error thrown by transformer")
            default:
                XCTFail()
            }
        }
        _ = cancellable

        storage.storeValue(storedValue, key: key)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnyStorageSettingWithoutTransformer() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage<Any>())
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = storedValue
        XCTAssertEqual(persisted.wrappedValue, storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnyStorageDeletingWithoutTransformer() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage<Any>())

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertNil(newValue, "Value passed to update listener should be nil to indicate delete")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = nil
        XCTAssertNil(persisted.wrappedValue, "Should return nil when value has been deleted")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnyStorageSettingWithTransformer() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage<Any>(), transformer: JSONTransformer())
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = storedValue
        XCTAssertEqual(persisted.wrappedValue, storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnyStorageDeletingWithTransformer() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        var persisted = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage<Any>(), transformer: JSONTransformer())

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertNil(newValue, "Value passed to update listener should be nil to indicate delete")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        persisted.wrappedValue = nil
        XCTAssertNil(persisted.wrappedValue, "Should return nil when value has been deleted")

        waitForExpectations(timeout: 1, handler: nil)
    }

}
#endif
