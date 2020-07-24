#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class NSUbiquitousKeyValueStoreValueTests: XCTestCase {

    func testDictionary() {
        let dictionary: [String: StorableInNSUbiquitousKeyValueStore] = [
            "foo": [1, 2, 3] as [Int64],
            "bar": true,
            "baz": "hello world",
            "double": 123.45 as Double,
            "data": "the-data".data(using: .utf8)!,
        ]

        let nsUbiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue(value: dictionary)
        XCTAssertEqual(
            nsUbiquitousKeyValueStoreValue,
            .dictionary([
                "foo": .array([.int64(1), .int64(2), .int64(3)]),
                "bar": .bool(true),
                "baz": .string("hello world"),
                "double": .double(123.45),
                "data": .data("the-data".data(using: .utf8)!),
            ])
        )
    }

    func testInitialiser() {
        XCTAssertEqual(NSUbiquitousKeyValueStoreValue(value: false), .bool(false))
        XCTAssertEqual(NSUbiquitousKeyValueStoreValue(value: true), .bool(true))
        XCTAssertEqual(NSUbiquitousKeyValueStoreValue(value: Int64(1234)), .int64(1234))
        XCTAssertEqual(NSUbiquitousKeyValueStoreValue(value: Double(1234.123)), .double(1234.123))
        XCTAssertEqual(NSUbiquitousKeyValueStoreValue(value: Data()), .data(Data()))
        XCTAssertEqual(NSUbiquitousKeyValueStoreValue(value: "test-value"), .string("test-value"))
        XCTAssertEqual(
            NSUbiquitousKeyValueStoreValue(value: [
                "test-value",
                Int64(123)
            ]),
            .array([
                .string("test-value"),
                .int64(123),
            ])
        )

        XCTAssertNil(NSUbiquitousKeyValueStoreValue(value: 123))
        XCTAssertNil(NSUbiquitousKeyValueStoreValue(value: [123]))
        XCTAssertNil(NSUbiquitousKeyValueStoreValue(value: ["unsupported-key": 123]))
    }

    func testInt64Casting() {
        XCTAssert(NSUbiquitousKeyValueStoreValue.int64(0).cast(to: Bool.self) == false)
        XCTAssert(NSUbiquitousKeyValueStoreValue.int64(1).cast(to: Bool.self) == true)
        XCTAssertNil(NSUbiquitousKeyValueStoreValue.int64(2).cast(to: Bool.self))
        XCTAssert(NSUbiquitousKeyValueStoreValue.int64(0).cast(to: Int64.self) == 0)
        XCTAssert(NSUbiquitousKeyValueStoreValue.int64(1).cast(to: Int64.self) == 1)
    }

    func testStringCasting() {
        XCTAssert(NSUbiquitousKeyValueStoreValue.string("test-string").cast(to: String.self) == "test-string")
        XCTAssertNil(NSUbiquitousKeyValueStoreValue.string("0").cast(to: Bool.self))
    }

}
#endif
