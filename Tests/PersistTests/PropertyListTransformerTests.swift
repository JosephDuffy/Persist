#if !os(watchOS)
import XCTest
@testable import Persist

final class PropertyListTransformerTests: XCTestCase {

    func testPropertyListTransformerWithCoderUserInfo() {
        let customKey = CodingUserInfoKey(rawValue: "test-key")!
        let customKeyValue = "the-value"
        let coderUserInfo: [CodingUserInfoKey: Any] = [
            customKey: customKeyValue,
        ]
        let transformer = PropertyListTransformer<String>(coderUserInfo: coderUserInfo)
        XCTAssertEqual(transformer.encoder.userInfo[customKey] as? String, customKeyValue)
        XCTAssertEqual(transformer.decoder.userInfo[customKey] as? String, customKeyValue)
    }

    func testPropertyListTransformerWithOutputFormat() {
        let outputFormat = PropertyListSerialization.PropertyListFormat.openStep
        let transformer = PropertyListTransformer<String>(outputFormat: outputFormat)
        XCTAssertEqual(transformer.encoder.outputFormat, outputFormat)
    }

    func testPropertyListTransformerWithCoderUserInfoAndOutputFormat() {
        let outputFormat = PropertyListSerialization.PropertyListFormat.openStep
        let customKey = CodingUserInfoKey(rawValue: "test-key")!
        let customKeyValue = "the-value"
        let coderUserInfo: [CodingUserInfoKey: Any] = [
            customKey: customKeyValue,
        ]
        let transformer = PropertyListTransformer<String>(outputFormat: outputFormat, coderUserInfo: coderUserInfo)
        XCTAssertEqual(transformer.encoder.userInfo[customKey] as? String, customKeyValue)
        XCTAssertEqual(transformer.encoder.outputFormat, outputFormat)
        XCTAssertEqual(transformer.decoder.userInfo[customKey] as? String, customKeyValue)
    }

    func testPropertyListTransformer() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }

        let storage = InMemoryStorage<Data>()
        let persisted = Persisted(
            wrappedValue: nil,
            key: "test-key",
            storedBy: storage,
            transformer: PropertyListTransformer(),
            valueType: StoredValue?.self
        )
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persisted.projectedValue.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        persisted.wrappedValue = storedValue
        XCTAssertEqual(persisted.wrappedValue, storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

}
#endif
