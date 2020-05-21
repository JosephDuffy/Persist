import XCTest
@testable import Persist

final class UserDefaultsStorageTests: XCTestCase {

    private let userDefaults = UserDefaults(suiteName: "test-suite")!

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testStoredInUserDefaults() {
        class Foo {
            @StoredInUserDefaults
            var bar: String?

            init(userDefaults: UserDefaults) {
                _bar = StoredInUserDefaults(key: "foo-bar", userDefaults: userDefaults)
            }
        }

        let foo = Foo(userDefaults: userDefaults)
        foo.bar = "new-value"
        XCTAssertEqual(userDefaults.string(forKey: "foo-bar"), "new-value")
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = userDefaults.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .string(value), "Value passed to update listener should be new value")
        }
        _ = cancellable

        userDefaults.storeValue(.string(value), key: key)

        XCTAssertEqual(userDefaults.string(forKey: key), value, "String should be stored as strings")
        XCTAssertEqual(userDefaults.retrieveValue(for: key), .string(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringArray() {
        let key = "key"
        let userDefaultsValue = UserDefaultsValue.array([
            .array([.int(1), .int(2), .int(3)]),
            .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = userDefaults.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, userDefaultsValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        userDefaults.storeValue(userDefaultsValue, key: key)

        XCTAssertNotNil(userDefaults.array(forKey: key), "Arrays should be stored as arrays")
        XCTAssertEqual(userDefaults.retrieveValue(for: key), userDefaultsValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDictionary() {
        let key = "key"
        let userDefaultsValue = UserDefaultsValue.dictionary([
            "foo": .array([.int(1), .int(2), .int(3)]),
            "bar": .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            "baz": .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = userDefaults.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, userDefaultsValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        userDefaults.storeValue(userDefaultsValue, key: key)

        XCTAssertNotNil(userDefaults.dictionary(forKey: key), "Dictionaries should be stored as dictionaries")
        XCTAssertEqual(userDefaults.retrieveValue(for: key), userDefaultsValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringURLs() {
        let url = URL(string: "http://example.com")!

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = userDefaults.addUpdateListener(forKey: "key") { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .url(url), "Value passed to update listener should be new value")
        }
        _ = cancellable

        userDefaults.storeValue(.url(url), key: "key")

        XCTAssertEqual(userDefaults.url(forKey: "key"), url, "URLs should be stored as URLs")
        XCTAssertEqual(userDefaults.retrieveValue(for: "key"), .url(url))
        XCTAssertNil(userDefaults.retrieveValue(for: "other"))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringTransformedValues() {
        struct Bar: Codable, Equatable {
            var baz: String
        }

        class Foo {
            @Persisted
            var bar: Bar?

            init(userDefaults: UserDefaults) {
                _bar = Persisted(key: "bar", userDefaults: userDefaults, transformer: JSONTransformer())
            }
        }

        let bar = Bar(baz: "new-value")
        let foo = Foo(userDefaults: userDefaults)
        foo.bar = bar
        XCTAssertNotNil(userDefaults.data(forKey: "bar"), "Should store transformed value")
        XCTAssertEqual(foo.bar, bar, "Should return untransformed value")
    }

    func testUpdateListenerWithStorageFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = userDefaults.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        userDefaults.storeValue(.string("test"), key: "test")

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

        let persister = Persister<String>(key: "test", userDefaults: userDefaults)
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
        let persister = Persister<String>(key: key, userDefaults: userDefaults)

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
