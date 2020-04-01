import XCTest
@testable import Persist

final class UserDefaultsStorageTests: XCTestCase {

    private let userDefaults = UserDefaults(suiteName: "test-suite")!

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testStoringStrings() {
        userDefaults.storeValue("test", key: "key")

        XCTAssertEqual(userDefaults.string(forKey: "key"), "test", "String should be stored as strings")
        XCTAssertEqual(try userDefaults.retrieveValue(for: "key"), "test")
    }

}
