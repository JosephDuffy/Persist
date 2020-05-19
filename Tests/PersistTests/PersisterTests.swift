import XCTest
@testable import Persist

final class PersisterTests: XCTestCase {

    func testStoringTransformedValue() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let persister = Persister<StoredValue?, InMemoryStorage>(key: "test", storedBy: InMemoryStorage(), transformer: JSONTransformer())
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
        XCTAssertNotNil(try persister.storage.retrieveValue(for: "test") as Data?, "Should store encoded data in storage")
        XCTAssertEqual(try persister.retrieveValue(), storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

}
