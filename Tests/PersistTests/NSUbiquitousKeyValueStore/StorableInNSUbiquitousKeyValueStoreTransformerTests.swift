#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class StorableInNSUbiquitousKeyValueStoreTransformerTests: XCTestCase {

    func testTransformBool() {
        let transformer = StorableInNSUbiquitousKeyValueStoreTransformer<Bool>()

        XCTAssertEqual(transformer.transformValue(true), .bool(true))
    }

    func testTransformString() {
        let transformer = StorableInNSUbiquitousKeyValueStoreTransformer<String>()

        XCTAssertEqual(transformer.transformValue("test-value"), .string("test-value"))
    }

    func testTransformData() {
        let transformer = StorableInNSUbiquitousKeyValueStoreTransformer<Data>()

        XCTAssertEqual(transformer.transformValue(Data()), .data(Data()))
    }

    func testTransformInt64() {
        let transformer = StorableInNSUbiquitousKeyValueStoreTransformer<Int64>()

        XCTAssertEqual(transformer.transformValue(Int64(123)), .int64(123))
    }

    func testTransformDouble() {
        let transformer = StorableInNSUbiquitousKeyValueStoreTransformer<Double>()

        XCTAssertEqual(transformer.transformValue(Double(123.45)), .double(123.45))
    }

    func testUntransformValue() {
        let valueToUntransform = "test-value"
        let transformer = StorableInNSUbiquitousKeyValueStoreTransformer<String>()

        XCTAssertEqual(try? transformer.untransformValue(.string(valueToUntransform)), valueToUntransform)
    }

    func testUntransformValueToDifferentValue() {
        let valueToUntransform = 123 as Int64
        let transformer = StorableInNSUbiquitousKeyValueStoreTransformer<String>()

        XCTAssertThrowsError(
            try transformer.untransformValue(.int64(valueToUntransform)),
            "Should throw error when untransforming value that cannot be cast to input",
            { error in
                switch error {
                case PersistenceError.unexpectedValueType(let value, let expected):
                    XCTAssertTrue(value is Int64)
                    XCTAssertEqual(valueToUntransform, value as? Int64)
                    XCTAssert(expected == String.self)
                default:
                    XCTFail("Should throw `PersistenceError.unexpectedValueType`")
                }
            }
        )
    }

}
#endif
