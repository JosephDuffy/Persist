import XCTest
@testable import Persist

final class PersistTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Persist().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
