#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class StorableInUserDefaultsTransformerTests: XCTestCase {
    func testTransformBool() throws {
        let transformer = StorableInUserDefaultsTransformer<Bool>()

        XCTAssertEqual(try transformer.transformValue(true), .bool(true))
    }

    func testTransformString() throws {
        let transformer = StorableInUserDefaultsTransformer<String>()

        XCTAssertEqual(try transformer.transformValue("test-value"), .string("test-value"))
    }

    func testTransformURL() throws {
        let transformer = StorableInUserDefaultsTransformer<URL>()

        let url = URL(string: "http://example.com/")!
        XCTAssertEqual(try transformer.transformValue(url), .url(url))
    }

    func testTransformData() throws {
        let transformer = StorableInUserDefaultsTransformer<Data>()

        XCTAssertEqual(try transformer.transformValue(Data()), .data(Data()))
    }

    func testTransformInt() throws {
        let transformer = StorableInUserDefaultsTransformer<Int>()

        XCTAssertEqual(try transformer.transformValue(123), .int(123))
    }

    func testTransformDouble() throws {
        let transformer = StorableInUserDefaultsTransformer<Double>()

        XCTAssertEqual(try transformer.transformValue(Double(123.45)), .double(123.45))
    }

    func testTransformFloat() throws {
        let transformer = StorableInUserDefaultsTransformer<Float>()

        XCTAssertEqual(try transformer.transformValue(Float(123.45)), .float(123.45))
    }

    func testUntransformValue() throws {
        let valueToUntransform = "test-value"
        let transformer = StorableInUserDefaultsTransformer<String>()

        XCTAssertEqual(try transformer.untransformValue(.string(valueToUntransform)), valueToUntransform)
    }

    func testUntransformValueToDifferentValue() {
        let valueToUntransform = 123
        let transformer = StorableInUserDefaultsTransformer<String>()

        XCTAssertThrowsError(
            try transformer.untransformValue(.int(valueToUntransform)),
            "Should throw error when untransforming value that cannot be cast to input",
            { error in
                switch error {
                case PersistenceError.unexpectedValueType(let value, let expected):
                    XCTAssertTrue(value is Int)
                    XCTAssertEqual(valueToUntransform, value as? Int)
                    XCTAssert(expected == String.self)
                default:
                    XCTFail("Should throw `PersistenceError.unexpectedValueType`")
                }
            }
        )
    }

    func testUnsupportedType() {
        struct UnsupportedType: StorableInUserDefaults {}
        let unsupportedValue = UnsupportedType()
        let transformer = StorableInUserDefaultsTransformer<UnsupportedType>()

        XCTAssertThrowsError(try transformer.transformValue(unsupportedValue))
    }
}
#endif
