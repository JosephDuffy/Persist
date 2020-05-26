#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class UbiquitousKeyValueStoreValueTests: XCTestCase {

    func testDictionary() {
        let dictionary: [String: StorableInUbiquitousKeyValueStore] = [
            "foo": [1, 2, 3] as [Int64],
            "bar": true,
            "baz": "hello world",
            "double": 123.45 as Double,
            "data": "the-data".data(using: .utf8)!,
        ]

        let userDefaultsValue = UbiquitousKeyValueStoreValue(value: dictionary)
        XCTAssertEqual(
            userDefaultsValue,
            .dictionary([
                "foo": .array([.int64(1), .int64(2), .int64(3)]),
                "bar": .bool(true),
                "baz": .string("hello world"),
                "double": .double(123.45),
                "data": .data("the-data".data(using: .utf8)!),
            ])
        )
    }

}
#endif
