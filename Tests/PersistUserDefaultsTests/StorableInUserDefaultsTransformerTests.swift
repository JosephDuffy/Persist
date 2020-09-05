#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import PersistUserDefaults
import PersistCore

final class StorableInUserDefaultsTransformerTests: XCTestCase {

    func testTransformBool() {
        let transformer = StorableInUserDefaultsTransformer<Bool>()

        XCTAssertEqual(transformer.transformValue(true), .bool(true))
    }

    func testTransformString() {
        let transformer = StorableInUserDefaultsTransformer<String>()

        XCTAssertEqual(transformer.transformValue("test-value"), .string("test-value"))
    }

    func testTransformURL() {
        let transformer = StorableInUserDefaultsTransformer<URL>()

        let url = URL(string: "http://example.com/")!
        XCTAssertEqual(transformer.transformValue(url), .url(url))
    }

    func testTransformData() {
        let transformer = StorableInUserDefaultsTransformer<Data>()

        XCTAssertEqual(transformer.transformValue(Data()), .data(Data()))
    }

    func testTransformInt() {
        let transformer = StorableInUserDefaultsTransformer<Int>()

        XCTAssertEqual(transformer.transformValue(123), .int(123))
    }

    func testTransformDouble() {
        let transformer = StorableInUserDefaultsTransformer<Double>()

        XCTAssertEqual(transformer.transformValue(Double(123.45)), .double(123.45))
    }

    func testTransformFloat() {
        let transformer = StorableInUserDefaultsTransformer<Float>()

        XCTAssertEqual(transformer.transformValue(Float(123.45)), .float(123.45))
    }

    func testUntransformValue() {
        let valueToUntransform = "test-value"
        let transformer = StorableInUserDefaultsTransformer<String>()

        XCTAssertEqual(try? transformer.untransformValue(.string(valueToUntransform)), valueToUntransform)
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

}
#endif
