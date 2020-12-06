#if !os(watchOS)
import XCTest
@testable import PersistCore
import TestHelpers

final class PersisterTests: XCTestCase {

    func testStoringValueWithAnyStorageType() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let storage = InMemoryStorage<Any>()
        let defaultValue = StoredValue(property: "default")
        let persister = Persister<StoredValue>(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
                XCTAssertEqual(update.event.value, storedValue, "Event value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.persist(storedValue)
        XCTAssertEqual(persister.retrieveValue(), storedValue, "Should retrieve stored value")
        XCTAssertEqual(storage.retrieveValue(for: "test") as? StoredValue, storedValue, "Should store value in storage")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStoringValueWithSpecficStorageType() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
                XCTAssertEqual(update.event.value, storedValue, "Event value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.persist(storedValue)
        XCTAssertEqual(persister.retrieveValue(), storedValue, "Should retrieve stored value")
        XCTAssertEqual(storage.retrieveValue(for: "test"), storedValue, "Should store value in storage")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStoringTransformedValue() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let storage = InMemoryStorage<StoredValue>()
        let defaultValue = StoredValue(property: "default")
        let persister = Persister<StoredValue>(key: "test", storedBy: storage, transformer: MockTransformer(), defaultValue: defaultValue)
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
                XCTAssertEqual(update.event.value, storedValue, "Event value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.persist(storedValue)
        XCTAssertNotNil(storage.retrieveValue(for: "test"), "Should store encoded data in storage")
        XCTAssertEqual(persister.retrieveValue(), storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRemovingValue() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        try persister.persist("stored-value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, defaultValue, "Value passed to update listener should be the default value")
                XCTAssertNil(update.event.value, "Event value passed to update listener should be `nil``")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.removeValue()
        XCTAssertNil(storage.retrieveValue(for: "test"), "Should remove value from storage")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValue() throws {
        let storage = InMemoryStorage<String>()
        let persister = Persister<String?>(key: "test", storedBy: storage)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
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

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithDefault() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister<String?>(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
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

        XCTAssert(persister.retrieveValue() == defaultValue, "Default value should be passed default value")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithAnyStorage() throws {
        let storage = InMemoryStorage<Any>()
        let persister = Persister<String?>(key: "test", storedBy: storage)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
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

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithAnyStorageWithDefault() throws {
        let storage = InMemoryStorage<Any>()
        let defaultValue = "default"
        let persister = Persister<String?>(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
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

        XCTAssert(persister.retrieveValue() == defaultValue, "Default value should be passed default value")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithTransformer() throws {
        let storage = InMemoryStorage<String>()
        let persister = Persister<String?>(key: "test", storedBy: storage, transformer: MockTransformer())
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
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

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithAnyStorageAnyTransformer() throws {
        let storage = InMemoryStorage<Any>()
        let persister = Persister<String?>(key: "test", storedBy: storage, transformer: MockTransformer())
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
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

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    #if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testSettingValueUpdatesPublisher() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.updatesPublisher.dropFirst().sink { newValue in
            XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the stored value")
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testRemovingValueUpdatesPublisher() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        try persister.persist("stored-value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.updatesPublisher.dropFirst().sink { newValue in
            XCTAssertEqual(newValue, defaultValue, "Value passed to update listener should be the default value")
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        try persister.removeValue()

        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif

}
#endif
