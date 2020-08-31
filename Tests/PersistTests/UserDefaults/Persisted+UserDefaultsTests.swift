#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class PersistedUserDefaultsTests: XCTestCase {

    private let userDefaults = UserDefaults(suiteName: "test-suite")!

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testValue_storedByInitialiser() throws {
        let defaultValue = "default"
        let persisted = Persisted<String>(key: "test", storedBy: userDefaults, defaultValue: defaultValue)
        let storedValue = "stored-value"

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

    func testValue_userDefaultsInitialiser() throws {
        let defaultValue = "default"
        let persisted = Persisted<String>(key: "test", userDefaults: userDefaults, defaultValue: defaultValue)
        let storedValue = "stored-value"

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
        let defaultValue = "default"
        let persisted = Persisted<String>(key: "test", storedBy: userDefaults, transformer: MockTransformer(), defaultValue: defaultValue)
        let storedValue = "stored-value"

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

    func testValueWithTransformer_userDefaultsInitialiser() throws {
        let defaultValue = "default"
        let persisted = Persisted<String>(key: "test", userDefaults: userDefaults, transformer: MockTransformer(), defaultValue: defaultValue)
        let storedValue = "stored-value"

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
        let persisted = Persisted<String?>(key: "test", storedBy: userDefaults)
        let storedValue = "stored-value"

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

    func testOptionalValue_userDefaultsInitialiser() throws {
        let persisted = Persisted<String?>(key: "test", userDefaults: userDefaults)
        let storedValue = "stored-value"

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
        let defaultValue = "default"
        let persisted = Persisted<String?>(key: "test", storedBy: userDefaults, defaultValue: defaultValue)
        let storedValue = "stored-value"

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

    func testOptionalValueWithDefault_userDefaultsInitialiser() throws {
        let defaultValue = "default"
        let persisted = Persisted<String?>(key: "test", userDefaults: userDefaults, defaultValue: defaultValue)
        let storedValue = "stored-value"

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
        let persisted = Persisted<String?>(key: "test", storedBy: userDefaults, transformer: MockTransformer())
        let storedValue = "stored-value"

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

    func testOptionalValueWithTransformer_userDefaultsInitialiser() throws {
        let persisted = Persisted<String?>(key: "test", userDefaults: userDefaults, transformer: MockTransformer())
        let storedValue = "stored-value"

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
