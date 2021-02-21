#if !os(watchOS)
import XCTest
@testable import Persist
import TestHelpers

final class AggregateTransformerTests: XCTestCase {

    func testTransformValue() {
        let firstTransformer = MockTransformer<String>()
        firstTransformer.transformedValue = "first-transformed"
        let secondTransformer = MockTransformer<String>()
        secondTransformer.transformedValue = "second-transformed"

        let aggregate = firstTransformer.append(transformer: secondTransformer)
        let input = "input"
        let transformed = try? aggregate.transformValue(input)

        XCTAssert(firstTransformer.transformValueParameter == input, "Input should be passed to first transformer")
        XCTAssertNotNil(secondTransformer.transformValueParameter, "Second transformer should be called")
        XCTAssert(secondTransformer.transformValueParameter == firstTransformer.transformedValue, "Output from first transformer should be passed to second transformer")
        XCTAssertNotNil(transformed, "Should return a value")
        XCTAssert(transformed == secondTransformer.transformedValue, "Should return output of second transformer")
    }

    func testUntransformValue() {
        let firstTransformer = MockTransformer<String>()
        firstTransformer.untransformedValue = "first-untransformed"
        let secondTransformer = MockTransformer<String>()
        secondTransformer.untransformedValue = "second-untransformed"

        let aggregate = firstTransformer.append(transformer: secondTransformer)
        let output = "output"
        let untransformed = try? aggregate.untransformValue(output)

        XCTAssert(secondTransformer.untransformValueParameter == output, "Input should be passed to first transformer")
        XCTAssertNotNil(firstTransformer.untransformValueParameter, "Second transformer should be called")
        XCTAssert(firstTransformer.untransformValueParameter == secondTransformer.untransformedValue, "Output from first transformer should be passed to second transformer")
        XCTAssertNotNil(untransformed, "Should return a value")
        XCTAssert(untransformed == firstTransformer.untransformedValue, "Should return output of second transformer")
    }

    func testTransformValueFirstTransformerThrows() {
        let firstTransformer = MockTransformer<String>()
        let secondTransformer = MockTransformer<String>()
        let thrownError = NSError(domain: "persist.tests", code: -1, userInfo: nil)
        firstTransformer.errorToThrow = thrownError

        let aggregate = firstTransformer.append(transformer: secondTransformer)
        let input = "input"
        XCTAssertThrowsError(
            try aggregate.transformValue(input),
            "Should throw when transformer throws",
            { error in
                XCTAssertEqual(error as NSError, thrownError, "Should throw error thrown by transformer")
            }
        )
    }

    func testTransformValueSecondTransformerThrows() {
        let firstTransformer = MockTransformer<String>()
        let secondTransformer = MockTransformer<String>()
        let thrownError = NSError(domain: "persist.tests", code: -1, userInfo: nil)
        secondTransformer.errorToThrow = thrownError

        let aggregate = firstTransformer.append(transformer: secondTransformer)
        let input = "input"
        XCTAssertThrowsError(
            try aggregate.transformValue(input),
            "Should throw when transformer throws",
            { error in
                XCTAssertEqual(error as NSError, thrownError, "Should throw error thrown by transformer")
            }
        )
    }

    func testUntransformValueFirstTransformerThrows() {
        let firstTransformer = MockTransformer<String>()
        let secondTransformer = MockTransformer<String>()
        let thrownError = NSError(domain: "persist.tests", code: -1, userInfo: nil)
        firstTransformer.errorToThrow = thrownError

        let aggregate = firstTransformer.append(transformer: secondTransformer)
        let output = "output"
        XCTAssertThrowsError(
            try aggregate.untransformValue(output),
            "Should throw when transformer throws",
            { error in
                XCTAssertEqual(error as NSError, thrownError, "Should throw error thrown by transformer")
            }
        )
    }

    func testUntransformValueSecondTransformerThrows() {
        let firstTransformer = MockTransformer<String>()
        let secondTransformer = MockTransformer<String>()
        let thrownError = NSError(domain: "persist.tests", code: -1, userInfo: nil)
        secondTransformer.errorToThrow = thrownError

        let aggregate = firstTransformer.append(transformer: secondTransformer)
        let output = "output"
        XCTAssertThrowsError(
            try aggregate.untransformValue(output),
            "Should throw when transformer throws",
            { error in
                XCTAssertEqual(error as NSError, thrownError, "Should throw error thrown by transformer")
            }
        )
    }

}
#endif
