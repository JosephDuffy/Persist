import XCTest
@testable import Persist

final class PersistedTests: XCTestCase {

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

}
