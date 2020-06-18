#if !os(watchOS)
import XCTest
@testable import Persist

final class JSONTransformerTests: XCTestCase {

    func testJSONTransformerWithCoderUserInfo() {
        let customKey = CodingUserInfoKey(rawValue: "test-key")!
        let customKeyValue = "the-value"
        let coderUserInfo: [CodingUserInfoKey: Any] = [
            customKey: customKeyValue,
        ]
        let transformer = JSONTransformer<CodableStruct>(coderUserInfo: coderUserInfo)
        XCTAssertEqual(transformer.encoder.userInfo[customKey] as? String, customKeyValue)
        XCTAssertEqual(transformer.decoder.userInfo[customKey] as? String, customKeyValue)
    }

}
#endif
