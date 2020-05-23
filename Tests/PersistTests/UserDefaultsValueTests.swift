#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import XCTest
@testable import Persist

final class UserDefaultsValueTests: XCTestCase {

    func testDictionary() {
        let dictionary: [String: StorableInUserDefaults] = [
            "foo": [1, 2, 3],
            "bar": true,
            "baz": "hello world",
        ]

        let userDefaultsValue = UserDefaultsValue(value: dictionary)
        XCTAssertEqual(
            userDefaultsValue,
            .dictionary([
                "foo": .array([.int(1), .int(2), .int(3)]),
                "bar": .bool(true),
                "baz": .string("hello world"),
            ])
        )
    }

}
#endif
