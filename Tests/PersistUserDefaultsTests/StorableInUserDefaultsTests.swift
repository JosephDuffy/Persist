#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import PersistUserDefaults

final class StorableInUserDefaultsTests: XCTestCase {

    func testBool() {
        XCTAssertEqual(true.asUserDefaultsValue, .bool(true))
    }

    func testString() {
        XCTAssertEqual("test-value".asUserDefaultsValue, .string("test-value"))
    }

    func testURL() {
        let url = URL(string: "http://example.com/")!
        XCTAssertEqual(url.asUserDefaultsValue, .url(url))
    }

    func testData() {
        XCTAssertEqual(Data().asUserDefaultsValue, .data(Data()))
    }

    func testInt() {
        XCTAssertEqual(123.asUserDefaultsValue, .int(123))
    }

    func testDouble() {
        XCTAssertEqual(Double(123.45).asUserDefaultsValue, .double(123.45))
    }

    func testArray() {
        XCTAssertEqual([123].asUserDefaultsValue, .array([.int(123)]))
    }

    func testDictionary() {
        XCTAssertEqual(
            [
                "test-key": 123
            ].asUserDefaultsValue,
            .dictionary([
                "test-key": .int(123)
            ])
        )
    }

}
#endif
