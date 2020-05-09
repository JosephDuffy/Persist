import XCTest
@testable import Persist

final class UserDefaultsStorageTests: XCTestCase {

    private let userDefaults = UserDefaults(suiteName: "test-suite")!

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = userDefaults.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertTrue(newValue is String, "Value passed to update listener should be a String")
            XCTAssertEqual(newValue as? String, value, "Value passed to update listener should be new value")
        }
        _ = cancellable

        userDefaults.storeValue(value, key: key)

        XCTAssertEqual(userDefaults.string(forKey: key),value, "String should be stored as strings")
        XCTAssertEqual(try userDefaults.retrieveValue(for: key), value)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringURLs() {
        let url = URL(string: "http://example.com")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = userDefaults.addUpdateListener(forKey: "key") { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertTrue(newValue is URL, "Value passed to update listener should be a URL")
            XCTAssertEqual(newValue as? URL, url, "Value passed to update listener should be new value")
        }
        _ = cancellable

        userDefaults.storeValue(url, key: "key")

        XCTAssertEqual(userDefaults.url(forKey: "key"), url, "URLs should be stored as URLs")
        XCTAssertEqual(try userDefaults.retrieveValue(for: "key"), url)
        XCTAssertNil(try userDefaults.retrieveValue(for: "other") as URL?)

        waitForExpectations(timeout: 0.1)
    }

    func testUpdateListenerWithStorageFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = userDefaults.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        userDefaults.storeValue("test", key: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerWithSetFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = userDefaults.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        userDefaults.set("test", forKey: "test")

        waitForExpectations(timeout: 1)
    }

    func testPersisterUpdateListenerUpdateViaUserDefaults() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")

        let persister = Persister<String, UserDefaults>(key: "test", storedBy: userDefaults)
        let cancellable = persister.addUpdateListener() { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        userDefaults.set("test", forKey: "test")

        waitForExpectations(timeout: 1)
    }

    func testPersisterUpdateListenerUpdateViaPersister() throws {
        let key = "test"
        let setValue = "value"
        let persister = Persister<String, UserDefaults>(key: key, storedBy: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let updateListenerCancellable = persister.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let value):
                XCTAssertEqual(value, setValue)
            case .failure(let error):
                XCTFail("Should return a success for updated values, not \(error)")
            }
        }
        _ = updateListenerCancellable

        var combineCancellable: Any?
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            let callsPublisherSubscribersExpectation = expectation(description: "Calls publisher subscribers")
            combineCancellable = persister.updatesPublisher.sink { result in
                defer {
                    callsPublisherSubscribersExpectation.fulfill()
                }

                switch result {
                case .success(let value):
                    XCTAssertEqual(value, setValue)
                case .failure:
                    XCTFail("Should return a success for updated values")
                }
            }
            _ = combineCancellable
        }

        try persister.persist(setValue)

        waitForExpectations(timeout: 1)
    }

}
