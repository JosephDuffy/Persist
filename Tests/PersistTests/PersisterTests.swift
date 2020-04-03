import XCTest
@testable import Persist

final class PersisterTests: XCTestCase {

    func testStoringTransformedValue() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let persister = Persister<StoredValue?>(key: "test", storedBy: InMemoryStorage(), transformer: JSONTransformer())
        let storedValue = StoredValue(property: "value")
        try persister.persist(storedValue)
        XCTAssertNotNil(try persister.storage.retrieveValue(for: "test") as Data?, "Should store encoded data in storage")
        XCTAssertEqual(try persister.retrieveValue(), storedValue, "Should return untransformed value")
    }

}
