#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class UserDefaultsValueTests: XCTestCase {

    func testDictionary() {
        let dictionary: [String: StorableInUserDefaults] = [
            "foo": [1, 2, 3],
            "bar": true,
            "baz": "hello world",
            "url": URL(string: "http://example.com")!,
        ]

        let userDefaultsValue = UserDefaultsValue(value: dictionary)
        XCTAssertEqual(
            userDefaultsValue,
            .dictionary([
                "foo": .array([.int(1), .int(2), .int(3)]),
                "bar": .bool(true),
                "baz": .string("hello world"),
                "url": .url(URL(string: "http://example.com")!),
            ])
        )
    }

    func testInitialiser() {
        XCTAssertEqual(UserDefaultsValue(value: false), .bool(false))
        XCTAssertEqual(UserDefaultsValue(value: true), .bool(true))
        XCTAssertEqual(UserDefaultsValue(value: 1234), .int(1234))
        XCTAssertEqual(UserDefaultsValue(value: Double(1234.123)), .double(1234.123))
        XCTAssertEqual(UserDefaultsValue(value: Data()), .data(Data()))
        XCTAssertEqual(UserDefaultsValue(value: "test-value"), .string("test-value"))
        XCTAssertEqual(
            UserDefaultsValue(value: [
                "test-value",
                123
            ]),
            .array([
                .string("test-value"),
                .int(123),
            ])
        )

        XCTAssertNil(UserDefaultsValue(value: Int64(123)))
        XCTAssertNil(UserDefaultsValue(value: [Int64(123)]))
        XCTAssertNil(UserDefaultsValue(value: ["unsupported-key": Int64(123)]))
    }

    func testStringCasting() {
        XCTAssert(UserDefaultsValue.string("test-string").cast(to: String.self) == "test-string")
        XCTAssertNil(UserDefaultsValue.string("0").cast(to: Bool.self))
    }

}
#endif
