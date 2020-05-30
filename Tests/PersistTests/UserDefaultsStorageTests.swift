#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class UserDefaultsStorageTests: XCTestCase {

    private let userDefaults = UserDefaults(suiteName: "test-suite")!

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testPersistedUserDefaultsAPI() {
        _ = Persisted<Int>(key: "test", storedBy: UserDefaults.standard)
        _ = Persisted<Int>(key: "test", storedBy: UserDefaultsStorage.standard)

        _ = Persisted<Int>(key: "test", userDefaults: .standard)
        _ = Persisted<Int>(key: "test", userDefaultsStorage: .standard)

        _ = Persisted<Int>(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer())
        _ = Persisted<Int>(key: "test", storedBy: UserDefaultsStorage.standard, transformer: MockTransformer())

        _ = Persisted<Int>(key: "test", userDefaults: .standard, transformer: MockTransformer())
        _ = Persisted<Int>(key: "test", userDefaultsStorage: .standard, transformer: MockTransformer())
    }

    func testPersisterUserDefaultsAPI() {
        _ = Persister<Int>(key: "test", storedBy: UserDefaults.standard)
        _ = Persister<Int>(key: "test", storedBy: UserDefaultsStorage.standard)

        _ = Persister<Int>(key: "test", userDefaults: .standard)
        _ = Persister<Int>(key: "test", userDefaultsStorage: .standard)

        _ = Persister<Int>(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer())
        _ = Persister<Int>(key: "test", storedBy: UserDefaultsStorage.standard, transformer: MockTransformer())

        _ = Persister<Int>(key: "test", userDefaults: .standard, transformer: MockTransformer())
        _ = Persister<Int>(key: "test", userDefaultsStorage: .standard, transformer: MockTransformer())
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

    func testPersisterWithURL() throws {
        let persister = Persister<URL>.init(key: "test", userDefaults: userDefaults)
        let url = URL(string: "http://example.com")!

        try persister.persist(url)
        XCTAssertEqual(try persister.retrieveValue(), url)
    }

    func testPersisterWithBoolFalse() throws {
        let persister = Persister<Bool>.init(key: "test", userDefaults: userDefaults)
        let bool = false

        try persister.persist(bool)
        XCTAssertEqual(try persister.retrieveValue(), bool)
    }

    func testPersisterWithBoolTrue() throws {
        let persister = Persister<Bool>.init(key: "test", userDefaults: userDefaults)
        let bool = true

        try persister.persist(bool)
        XCTAssertEqual(try persister.retrieveValue(), bool)
    }

    func testPersisterWithInt() throws {
        let persister = Persister<Int>.init(key: "test", userDefaults: userDefaults)
        let int = 0

        try persister.persist(int)
        XCTAssertEqual(try persister.retrieveValue(), int)
    }

    func testPersisterWithDouble() throws {
        let persister = Persister<Double>.init(key: "test", userDefaults: userDefaults)
        let double = 1.23

        try persister.persist(double)
        XCTAssertEqual(try persister.retrieveValue(), double)
    }

    func testPersisterWithFloat() throws {
        let persister = Persister<Float>.init(key: "test", userDefaults: userDefaults)
        let float: Float = 1.23

        try persister.persist(float)
        XCTAssertEqual(try persister.retrieveValue()!, float, accuracy: 0.1)
    }

    func testPersisterWithArray() throws {
        let persister = Persister<[Int]>.init(key: "test", userDefaults: userDefaults)
        let array = [1, 2, 0, 6]

        try persister.persist(array)
        XCTAssertEqual(try persister.retrieveValue(), array)
    }

    func testPersisterWithDictionary() throws {
        let persister = Persister<[String: [Int]]>.init(key: "test", userDefaults: userDefaults)
        let dictionary = [
            "foo": [1, 2, 0, 6],
            "bar": [0, 4, 7],
        ]

        try persister.persist(dictionary)
        XCTAssertEqual(try persister.retrieveValue(), dictionary)
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"
        let storage = UserDefaultsStorage(userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = storage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .string(value), "Value passed to update listener should be new value")
        }
        _ = cancellable

        storage.storeValue(.string(value), key: key)

        XCTAssertEqual(userDefaults.string(forKey: key), value, "String should be stored as strings")
        XCTAssertEqual(storage.retrieveValue(for: key), .string(value))

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
        let storage = UserDefaultsStorage(userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = storage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, userDefaultsValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        storage.storeValue(userDefaultsValue, key: key)

        XCTAssertNotNil(userDefaults.array(forKey: key), "Arrays should be stored as arrays")
        XCTAssertEqual(storage.retrieveValue(for: key), userDefaultsValue)

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
        let storage = UserDefaultsStorage(userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = storage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, userDefaultsValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        storage.storeValue(userDefaultsValue, key: key)

        XCTAssertNotNil(userDefaults.dictionary(forKey: key), "Dictionaries should be stored as dictionaries")
        XCTAssertEqual(storage.retrieveValue(for: key), userDefaultsValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringURLs() {
        let url = URL(string: "http://example.com")!
        let storage = UserDefaultsStorage(userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = storage.addUpdateListener(forKey: "key") { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .url(url), "Value passed to update listener should be new value")
        }
        _ = cancellable

        storage.storeValue(.url(url), key: "key")

        XCTAssertEqual(userDefaults.url(forKey: "key"), url, "URLs should be stored as URLs")
        XCTAssertEqual(storage.retrieveValue(for: "key"), .url(url))
        XCTAssertNil(storage.retrieveValue(for: "other"))

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
        let storage = UserDefaultsStorage(userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = storage.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        storage.storeValue(.string("test"), key: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerWithSetFunction() {
        let storage = UserDefaultsStorage(userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = storage.addUpdateListener(forKey: "test") { _ in
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
#endif
