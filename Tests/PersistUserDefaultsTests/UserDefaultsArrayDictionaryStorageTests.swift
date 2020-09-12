#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import PersistUserDefaults

final class UserDefaultsArrayDictionaryStorageTests: XCTestCase {
    private let userDefaultsStorage = UserDefaultsStorage(suiteName: "test-suite")!

    override func tearDown() {
        let userDefaults = userDefaultsStorage.userDefaults
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testUpdateListener() throws {
        let storage = UserDefaultsArrayDictionaryStorage(arrayKey: "TestArray", arrayIndex: 0, userDefaults: userDefaultsStorage.userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = storage.addUpdateListener(forKey: "foo") { update in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        try storage.storeValue(.string("123"), key: "foo")

        waitForExpectations(timeout: 1)
    }
}
#endif
