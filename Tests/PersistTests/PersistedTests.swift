#if !os(watchOS)
import XCTest
@testable import Persist

final class PersistedTests: XCTestCase {

    func testAnyAPI() {
        _ = Persisted<String?>(key: "test-key", storedBy: InMemoryStorage<Any>())
        _ = Persisted<String>(key: "test-key", storedBy: InMemoryStorage<Any>(), defaultValue: "default")
    }

    func testAnyAPIWithTransformer() {
        struct StoredValue: Codable, Equatable {
            let property: String
        }

        _ = Persisted<StoredValue?>(key: "test-key", storedBy: InMemoryStorage<Any>(), transformer: JSONTransformer())
        _ = Persisted<StoredValue>(key: "test-key", storedBy: InMemoryStorage<Any>(), transformer: JSONTransformer(), defaultValue: StoredValue(property: "default"))
    }

    func testStoredValueSameAsStorage() throws {
        let defaultValue = "default-value"
        let storage = InMemoryStorage<String>()
        let persisted = Persisted(key: "test-key", storedBy: storage, defaultValue: defaultValue)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return the default value when a value has not been set")

        let newValue = "new-value"

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 2
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount == 0 {
                    XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
                } else if callCount == 1 {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { newValue in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .success(let update):
                XCTAssertEqual(update, .persisted("new-value"), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")

        secondSubscription.cancel()

        try persisted.projectedValue.removeValue()

        XCTAssertEqual(persisted.wrappedValue, persisted.projectedValue.defaultValue, "`wrappedValue` should return the default value when a value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testStoredOptionalValueSameAsStorage() throws {
        let key = "test-key"
        let storage = InMemoryStorage<String>()
        let persisted = Persisted<String?>(key: key, storedBy: storage)
        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when a value has not been set")

        let newValue = "new-value"

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 4
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount % 2 == 0 {
                    XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
                } else {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { newValue in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .success(let update):
                XCTAssertEqual(update, .persisted("new-value"), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")

        secondSubscription.cancel()

        persisted.wrappedValue = nil

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when the value has been set to `nil`")

        storage.storeValue(newValue, key: key)

        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via the storage")

        try persisted.projectedValue.removeValue()

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when the value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNonOptionalValueWithAnyStorage() throws {
        let defaultValue = "default-value"
        let storage = InMemoryStorage<Any>()
        let persisted = Persisted(key: "test-key", storedBy: storage, defaultValue: defaultValue)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return the default value when a value has not been set")

        let newValue = "new-value"

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 2
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount == 0 {
                    XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
                } else if callCount == 1 {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { newValue in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .success(let update):
                XCTAssertEqual(update, .persisted("new-value"), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")

        secondSubscription.cancel()

        try persisted.projectedValue.removeValue()

        XCTAssertEqual(persisted.wrappedValue, persisted.projectedValue.defaultValue, "`wrappedValue` should return the default value when a value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testOptionalValueWithAnyStorage() throws {
        let key = "test-key"
        let storage = InMemoryStorage<Any>()
        let persisted = Persisted<String?>(key: key, storedBy: storage)
        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when a value has not been set")

        let newValue = "new-value"

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 4
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount % 2 == 0 {
                    XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
                } else {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { newValue in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .success(let update):
                XCTAssertEqual(update, .persisted("new-value"), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")

        secondSubscription.cancel()

        persisted.wrappedValue = nil

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when the value has been set to `nil`")

        storage.storeValue(newValue, key: key)

        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via the storage")

        try persisted.projectedValue.removeValue()

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when the value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNonOptionalValueWithAnyStorageDifferentStoredValueType() throws {
        let key = "test-key"
        let defaultValue = "default-value"
        let storage = InMemoryStorage<Any>()
        let storedValue = 123
        let persisted = Persisted(key: key, storedBy: storage, defaultValue: defaultValue)

        let callsUpdateListenerExpectation = expectation(description: "Calls first update listener")
        let subscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == String.self)
            default:
                XCTFail()
            }
        }
        _ = subscription

        storage.storeValue(storedValue, key: key)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return default value when underlying value is of a different type")

        XCTAssertThrowsError(try persisted.projectedValue.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == String.self)
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testOptionalValueWithAnyStorageDifferentStoredValueType() throws {
        let key = "test-key"
        let storage = InMemoryStorage<Any>()
        let storedValue = 123
        let persisted = Persisted<String?>(key: key, storedBy: storage)

        let callsUpdateListenerExpectation = expectation(description: "Calls first update listener")
        let subscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == String.self)
            default:
                XCTFail()
            }
        }
        _ = subscription

        storage.storeValue(storedValue, key: key)
        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when underlying value is of a different type")

        XCTAssertThrowsError(try persisted.projectedValue.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == String.self)
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNonOptionalValueWithAnyStorageAndTransformer() throws {
        let defaultValue: CodableStruct = "default-value"
        let storage = InMemoryStorage<Any>()
        let transformer = JSONTransformer<CodableStruct>()
        let persisted = Persisted(key: "test-key", storedBy: storage, transformer: transformer, defaultValue: defaultValue)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return the default value when a value has not been set")

        let newValue: CodableStruct = "new-value"

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 2
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount == 0 {
                    XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
                } else if callCount == 1 {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")
        XCTAssertTrue(storage.retrieveValue(for: "test-key") is Data, "Stored value should be transformer output")

        secondSubscription.cancel()

        try persisted.projectedValue.removeValue()

        XCTAssertEqual(persisted.wrappedValue, persisted.projectedValue.defaultValue, "`wrappedValue` should return the default value when a value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNonOptionalValueWithAnyStorageAndTransformerDifferentStoredValueType() throws {
        let key = "test-key"
        let storage = InMemoryStorage<Any>()
        let transformer = JSONTransformer<CodableStruct>()
        let defaultValue: CodableStruct = "default-value"
        let storedValue = 123
        let persisted = Persisted(key: key, storedBy: storage, transformer: transformer, defaultValue: defaultValue)

        let callsUpdateListenerExpectation = expectation(description: "Calls first update listener")
        let subscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == Data.self, "Should expect output of formatter")
            default:
                XCTFail()
            }
        }
        _ = subscription

        storage.storeValue(storedValue, key: key)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return default value when underlying value is of a different type")

        XCTAssertThrowsError(try persisted.projectedValue.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == Data.self, "Should expect output of formatter")
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNonOptionalValueWithAnyStorageAndTransformerThrowingError() throws {
        let key = "test-key"
        let storage = InMemoryStorage<Any>()
        let transformer = MockTransformer<String>()
        let errorToThrow = NSError(domain: "tests", code: -1, userInfo: nil)
        transformer.errorToThrow = errorToThrow
        let defaultValue = "default-value"
        let storedValue = "stored-value"
        let persisted = Persisted<String>(key: key, storedBy: storage, transformer: transformer, defaultValue: defaultValue)

        let callsUpdateListenerExpectation = expectation(description: "Calls first update listener")
        let subscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, errorToThrow, "Should pass error thrown by transformer")
            default:
                XCTFail()
            }
        }
        _ = subscription

        storage.storeValue(storedValue, key: key)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return default value when underlying value is of a different type")

        XCTAssertThrowsError(try persisted.projectedValue.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            XCTAssertEqual(error as NSError, errorToThrow, "Should pass error thrown by transformer")
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testOptionalValueWithAnyStorageAndTransformerDifferentStoredValueType() throws {
        let key = "test-key"
        let storage = InMemoryStorage<Any>()
        let transformer = JSONTransformer<CodableStruct>()
        let storedValue = 123
        let persisted = Persisted<CodableStruct?>(key: key, storedBy: storage, transformer: transformer)

        let callsUpdateListenerExpectation = expectation(description: "Calls first update listener")
        let subscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == Data.self, "Should expect output of formatter")
            default:
                XCTFail()
            }
        }
        _ = subscription

        storage.storeValue(storedValue, key: key)
        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when transformer throws an error")

        XCTAssertThrowsError(try persisted.projectedValue.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? Int, storedValue)
                XCTAssert(expected == Data.self, "Should expect output of formatter")
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testOptionalValueWithAnyStorageAndTransformerThrowingError() throws {
        let key = "test-key"
        let storage = InMemoryStorage<Any>()
        let transformer = MockTransformer<String>()
        let errorToThrow = NSError(domain: "tests", code: -1, userInfo: nil)
        transformer.errorToThrow = errorToThrow
        let storedValue = "stored-value"
        let persisted = Persisted<String?>(key: key, storedBy: storage, transformer: transformer)

        let callsUpdateListenerExpectation = expectation(description: "Calls first update listener")
        let subscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, errorToThrow, "Should pass error thrown by transformer")
            default:
                XCTFail()
            }
        }
        _ = subscription

        storage.storeValue(storedValue, key: key)
        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return be `nil` when transformer throws an error")

        XCTAssertThrowsError(try persisted.projectedValue.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            XCTAssertEqual(error as NSError, errorToThrow, "Should pass error thrown by transformer")
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testOptionalValueWithAnyStorageAndTransformer() throws {
        let storage = InMemoryStorage<Any>()
        let transformer = JSONTransformer<CodableStruct>()
        let persisted = Persisted<CodableStruct?>(key: "test-key", storedBy: storage, transformer: transformer)
        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when a value has not been set")

        let newValue: CodableStruct = "new-value"

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 4
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount % 2 == 0 {
                    XCTAssertEqual(update, .persisted("new-value"), "Update listener should receive `persisted` update with new value")
                } else  {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { newValue in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .success(let update):
                XCTAssertEqual(update, .persisted("new-value"), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")
        XCTAssertTrue(storage.retrieveValue(for: "test-key") is Data, "Stored value should be transformer output")

        secondSubscription.cancel()

        persisted.wrappedValue = nil

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when `wrappedValue` has been set to `nil`")

        persisted.wrappedValue = newValue

        try persisted.projectedValue.removeValue()

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when a value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNonOptionalValueWithTransformer() throws {
        struct CodableType: Codable, Equatable {
            let property: String
        }
        let defaultValue = CodableType(property: "default-value")
        let storage = InMemoryStorage<Data>()
        let transformer = JSONTransformer<CodableType>()
        let persisted = Persisted(key: "test-key", storedBy: storage, transformer: transformer, defaultValue: defaultValue)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return the default value when a value has not been set")

        let newValue = CodableType(property: "new-value")

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 2
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount == 0 {
                    XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
                } else if callCount == 1 {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")

        secondSubscription.cancel()

        try persisted.projectedValue.removeValue()

        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return the default value when a value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testNonOptionalValueWithThrowingTransformer() {
        let key = "test-key"
        let storage = InMemoryStorage<String>()
        let transformer = MockTransformer<String>()
        let errorToThrow = NSError(domain: "tests", code: -1, userInfo: nil)
        transformer.errorToThrow = errorToThrow
        let storedValue = "stored-value"
        let defaultValue = "default-value"
        let persisted = Persisted<String>(key: key, storedBy: storage, transformer: transformer, defaultValue: defaultValue)

        let callsUpdateListenerExpectation = expectation(description: "Calls first update listener")
        let subscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .failure(let error):
                XCTAssertEqual(error as NSError, errorToThrow, "Should pass error thrown by transformer")
            default:
                XCTFail()
            }
        }
        _ = subscription

        storage.storeValue(storedValue, key: key)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "`wrappedValue` should return default value when transformer throws an error")

        XCTAssertThrowsError(try persisted.projectedValue.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            XCTAssertEqual(error as NSError, errorToThrow, "Should pass error thrown by transformer")
        }

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testOptionalValueWithTransformer() throws {
        let storage = InMemoryStorage<Data>()
        let transformer = JSONTransformer<CodableStruct>()
        let persisted = Persisted<CodableStruct?>(key: "test-key", storedBy: storage, transformer: transformer)
        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when a value has not been set")

        let newValue: CodableStruct = "new-value"

        let callsFirstUpdateListenerExpectationTwice = expectation(description: "Calls first update listener twice")
        callsFirstUpdateListenerExpectationTwice.expectedFulfillmentCount = 4
        var callCount = 0
        let firstSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsFirstUpdateListenerExpectationTwice.fulfill()
                callCount += 1
            }

            switch result {
            case .success(let update):
                if callCount % 2 == 0 {
                    XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
                } else {
                    XCTAssertEqual(update.event, .removed, "Update listener should receive `removed` update")
                }
            case .failure:
                XCTFail("Update should not fail")
            }
        }
        _ = firstSubscription

        let callsSecondUpdateListenerExpectation = expectation(description: "Calls second update listener")
        let secondSubscription = persisted.projectedValue.addUpdateListener() { result in
            defer {
                callsSecondUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update, .persisted(newValue), "Update listener should receive `persisted` update with new value")
            case .failure:
                XCTFail("Update should not fail")
            }
        }

        persisted.wrappedValue = newValue
        XCTAssertEqual(persisted.wrappedValue, newValue, "`wrappedValue` should return the value that been set via `wrappedValue`")

        secondSubscription.cancel()

        persisted.wrappedValue = nil

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when `wrappedValue` has been set to `nil`")

        persisted.wrappedValue = newValue

        try persisted.projectedValue.removeValue()

        XCTAssertNil(persisted.wrappedValue, "`wrappedValue` should return `nil` when a value has been removed")

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testAnyStorageSettingWithDifferentStoredValueType() throws {
        let key = "key"
        let actualValue = "test"
        let storage = InMemoryStorage<Any>()
        let persister = Persister<Int?>(key: key, storedBy: storage)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener() { newValue in
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
        _ = subscription

        storage.storeValue(actualValue, key: "key")

        XCTAssertThrowsError(try persister.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
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
        let persister = Persister<Int?>(key: key, storedBy: storage, transformer: JSONTransformer())

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener() { newValue in
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
        _ = subscription

        storage.storeValue(actualValue, key: "key")

        XCTAssertThrowsError(try persister.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
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
        let persister = Persister<Int?>(key: key, storedBy: storage, transformer: transformer)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener() { newValue in
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
        _ = subscription

        storage.storeValue(actualValue, key: key)

        XCTAssertThrowsError(try persister.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
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

    func testDefaultValueStoreWhenNil() {
        let key = "test-key"
        let defaultValue = "default"
        let storage = InMemoryStorage<String>()
        let transformer = MockTransformer<String>()
        let persisted = Persisted<String?>(key: key, storedBy: storage, transformer: transformer, defaultValue: defaultValue, defaultValuePersistBehaviour: .persistWhenNil)

        transformer.errorToThrow = NSError(domain: "perist-tests", code: 1, userInfo: nil)
        XCTAssertEqual(persisted.wrappedValue, defaultValue)
        XCTAssertNil(storage.retrieveValue(for: key), "Default value should not be persisted when error is thrown")

        transformer.errorToThrow = nil

        XCTAssertEqual(persisted.wrappedValue, defaultValue)
        XCTAssertEqual(storage.retrieveValue(for: key), defaultValue, "Default value should be persisted when retrieved")

        let updatedValue = "update-value"
        persisted.wrappedValue = updatedValue

        XCTAssertEqual(persisted.wrappedValue, updatedValue)
        XCTAssertEqual(storage.retrieveValue(for: key), updatedValue, "Updated value should be persisted when set")
    }

    func testDefaultValueStoreOnError() {
        let key = "test-key"
        let defaultValue = "default"
        let storage = InMemoryStorage<String>()
        let transformer = MockTransformer<String>()
        let persisted = Persisted<String?>(key: key, storedBy: storage, transformer: transformer, defaultValue: defaultValue, defaultValuePersistBehaviour: .persistOnError)

        XCTAssertEqual(persisted.wrappedValue, defaultValue)
        XCTAssertNil(storage.retrieveValue(for: key), "Default value should not be persisted when nil is returned")

        transformer.errorToThrow = NSError(domain: "perist-tests", code: 1, userInfo: nil)
        storage.storeValue("another-value", key: key)

        XCTAssertEqual(persisted.wrappedValue, defaultValue)
        XCTAssertEqual(persisted.wrappedValue, defaultValue, "Default value should be persisted when error is thrown")

        transformer.errorToThrow = nil
        let updatedValue = "update-value"
        persisted.wrappedValue = updatedValue

        XCTAssertEqual(persisted.wrappedValue, updatedValue)
        XCTAssertEqual(storage.retrieveValue(for: key), updatedValue, "Updated value should be persisted when set")
    }

    func testDefaultValue() {
        let key = "test-key"
        let defaultValue = "default"
        let storage = InMemoryStorage<String>()
        let persisted = Persisted<String?>(key: key, storedBy: storage, defaultValue: defaultValue)

        XCTAssertEqual(persisted.wrappedValue, defaultValue)
        XCTAssertNil(storage.retrieveValue(for: key), "Default value should not be persisted when retrieved")

        let updatedValue = "update-value"
        persisted.wrappedValue = updatedValue

        XCTAssertEqual(persisted.wrappedValue, updatedValue)
        XCTAssertEqual(storage.retrieveValue(for: key), updatedValue, "Updated value should be persisted when set")
    }

    func testDefaultValueIsEvaluatedLazily() {
        final class Foo {
            init(onInit: () -> Void) {
                onInit()
            }
        }

        var initCallCount = 0

        let key = "test-key"
        let storage = InMemoryStorage<Foo>()
        let persisted = Persisted(key: key, storedBy: storage, defaultValue: Foo(onInit: { initCallCount += 1 }))

        XCTAssertTrue(initCallCount == 0, "Should not initialise default value during initalisation")

        _ = persisted.projectedValue.defaultValue

        XCTAssertTrue(initCallCount == 1, "Accessing default value should initialise default value")

        _ = persisted.projectedValue.defaultValue

        XCTAssertTrue(initCallCount == 1, "Multiple accesses to default value should initialise default value once")
    }

    func testOptionalDefaultValueIsEvaluatedLazily() {
        final class Foo {
            init(onInit: () -> Void) {
                onInit()
            }
        }

        var initCallCount = 0

        let key = "test-key"
        let storage = InMemoryStorage<Foo>()
        let persisted = Persisted<Foo?>(key: key, storedBy: storage, defaultValue: Foo(onInit: { initCallCount += 1 }))

        XCTAssertTrue(initCallCount == 0, "Should not initialise default value during initalisation")

        _ = persisted.projectedValue.defaultValue

        XCTAssertTrue(initCallCount == 1, "Accessing default value should initialise default value")

        _ = persisted.projectedValue.defaultValue

        XCTAssertTrue(initCallCount == 1, "Multiple accesses to default value should initialise default value once")
    }

    func testOptionalDefaultValueWithTransformerIsEvaluatedLazily() {
        final class Foo {
            init(onInit: () -> Void) {
                onInit()
            }
        }

        var initCallCount = 0

        let key = "test-key"
        let storage = InMemoryStorage<Foo>()
        let persisted = Persisted<Foo?>(key: key, storedBy: storage, transformer: MockTransformer<Foo>(), defaultValue: Foo(onInit: { initCallCount += 1 }))

        XCTAssertTrue(initCallCount == 0, "Should not initialise default value during initalisation")

        _ = persisted.projectedValue.defaultValue

        XCTAssertTrue(initCallCount == 1, "Accessing default value should initialise default value")

        _ = persisted.projectedValue.defaultValue

        XCTAssertTrue(initCallCount == 1, "Multiple accesses to default value should initialise default value once")
    }

}
#endif
