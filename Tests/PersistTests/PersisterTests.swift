#if !os(watchOS)
import XCTest
@testable import Persist

final class PersisterTests: XCTestCase {

    func testStoringValueWithAnyStorageType() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let storage = InMemoryStorage()
        let persister = Persister<StoredValue>(key: "test", storedBy: storage)
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        try persister.persist(storedValue)
        XCTAssertEqual(try persister.retrieveValue(), storedValue, "Should store value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStoringValueWithSpecficStorageType() throws {
        let storage = UserDefaults(suiteName: "test-suite")!
        let persister = Persister<UserDefaultsValue>(key: "test", storedBy: storage)
        let storedValue = UserDefaultsValue.string("stored-value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        try persister.persist(storedValue)
        XCTAssertEqual(try persister.retrieveValue(), storedValue, "Should store value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStoringTransformedValue() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let storage = InMemoryStorage()
        let persister = Persister<StoredValue>(key: "test", storedBy: storage, transformer: JSONTransformer())
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let newValue):
                XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = cancellable

        try persister.persist(storedValue)
        XCTAssert(storage.retrieveValue(for: "test") is Data, "Should store encoded data in storage")
        XCTAssertEqual(try persister.retrieveValue(), storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

}
#endif
