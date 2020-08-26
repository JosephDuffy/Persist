#if !os(watchOS)
import XCTest
@testable import Persist

final class RawRepresentableTransformerTests: XCTestCase {

    func testRepresentableTransformer() throws {
        enum TestType: Int {
            case first = 1
            case second = 2
        }

        let transformer = RawRepresentableTransformer<TestType>()
        let input = TestType.first
        let transformedInput = transformer.transformValue(input)

        XCTAssertEqual(transformedInput, input.rawValue)

        let output = TestType.second.rawValue
        let untransformedOutput = try transformer.untransformValue(output)

        XCTAssertEqual(untransformedOutput, TestType.second)

        let unsupporedRawValue = 3
        XCTAssertThrowsError(try transformer.untransformValue(unsupporedRawValue)) { thrownError in
            switch thrownError {
            case RawRepresentableTransformer<TestType>.UntransformError.invalidRawValue(unsupporedRawValue):
                // Use to bump coverage, not particularly useful
                _ = thrownError.localizedDescription
            default:
                XCTFail("Should throw `invalidRawValue` error with passed raw value")
            }
        }
    }

}
#endif
