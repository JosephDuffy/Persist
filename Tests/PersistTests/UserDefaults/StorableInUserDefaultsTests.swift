#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

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

    func testDate() {
        let date = Date()
        XCTAssertEqual(date.asUserDefaultsValue, .date(date))
    }

    func testNSNumber() {
        XCTAssertEqual(NSNumber(123).asUserDefaultsValue, .number(NSNumber(123)))
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
