#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import Persist

final class UserDefaultsStorageTests: XCTestCase {

    private let userDefaults = UserDefaults(suiteName: "test-suite")!

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testPersistedUserDefaultsAPI() {
        _ = Persisted<Double?>(key: "test", storedBy: UserDefaults.standard)
        _ = Persisted<Double?>(key: "test", storedBy: UserDefaultsStorage.standard)
        _ = Persisted(key: "test", storedBy: UserDefaults.standard, defaultValue: 123)
        _ = Persisted(key: "test", storedBy: UserDefaultsStorage.standard, defaultValue: 123)

        _ = Persisted<Double?>(key: "test", userDefaults: .standard)
        _ = Persisted<Double?>(key: "test", userDefaultsStorage: .standard)
        _ = Persisted(key: "test", userDefaults: .standard, defaultValue: 123)
        _ = Persisted(key: "test", userDefaultsStorage: .standard, defaultValue: 123)

        _ = Persisted<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer())
        _ = Persisted<Double?>(key: "test", storedBy: UserDefaultsStorage.standard, transformer: MockTransformer())
        _ = Persisted(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer(), defaultValue: 123)
        _ = Persisted(key: "test", storedBy: UserDefaultsStorage.standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer())
        _ = Persisted<Double?>(key: "test", storedBy: UserDefaultsStorage.standard, transformer: JSONTransformer())
        _ = Persisted(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer(), defaultValue: 123)
        _ = Persisted(key: "test", storedBy: UserDefaultsStorage.standard, transformer: JSONTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", userDefaults: .standard, transformer: MockTransformer())
        _ = Persisted<Double?>(key: "test", userDefaultsStorage: .standard, transformer: MockTransformer())
        _ = Persisted(key: "test", userDefaults: .standard, transformer: MockTransformer(), defaultValue: 123)
        _ = Persisted(key: "test", userDefaultsStorage: .standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", userDefaults: .standard, transformer: JSONTransformer())
        _ = Persisted<Double?>(key: "test", userDefaultsStorage: .standard, transformer: JSONTransformer())
        _ = Persisted(key: "test", userDefaults: .standard, transformer: JSONTransformer(), defaultValue: 123)
        _ = Persisted(key: "test", userDefaultsStorage: .standard, transformer: JSONTransformer(), defaultValue: 123)
    }

    func testPersisterUserDefaultsAPI() {
        _ = Persister<Double?>(key: "test", storedBy: UserDefaults.standard)
        _ = Persister<Double?>(key: "test", storedBy: UserDefaultsStorage.standard)
        _ = Persister(key: "test", storedBy: UserDefaults.standard, defaultValue: 123)
        _ = Persister(key: "test", storedBy: UserDefaultsStorage.standard, defaultValue: 123)

        _ = Persister<Double?>(key: "test", userDefaults: .standard)
        _ = Persister<Double?>(key: "test", userDefaultsStorage: .standard)
        _ = Persister(key: "test", userDefaults: .standard, defaultValue: 123)
        _ = Persister(key: "test", userDefaultsStorage: .standard, defaultValue: 123)

        _ = Persister<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer())
        _ = Persister<Double?>(key: "test", storedBy: UserDefaultsStorage.standard, transformer: MockTransformer())
        _ = Persister(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer(), defaultValue: 123)
        _ = Persister(key: "test", storedBy: UserDefaultsStorage.standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer())
        _ = Persister<Double?>(key: "test", storedBy: UserDefaultsStorage.standard, transformer: JSONTransformer())
        _ = Persister(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer(), defaultValue: 123)
        _ = Persister(key: "test", storedBy: UserDefaultsStorage.standard, transformer: JSONTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", userDefaults: .standard, transformer: MockTransformer())
        _ = Persister<Double?>(key: "test", userDefaultsStorage: .standard, transformer: MockTransformer())
        _ = Persister(key: "test", userDefaults: .standard, transformer: MockTransformer(), defaultValue: 123)
        _ = Persister(key: "test", userDefaultsStorage: .standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", userDefaults: .standard, transformer: JSONTransformer())
        _ = Persister<Double?>(key: "test", userDefaultsStorage: .standard, transformer: JSONTransformer())
        _ = Persister(key: "test", userDefaults: .standard, transformer: JSONTransformer(), defaultValue: 123)
        _ = Persister(key: "test", userDefaultsStorage: .standard, transformer: JSONTransformer(), defaultValue: 123)
    }

    func testUserDefaultsStorageSuiteNameInitialiser() {
        let storage = UserDefaultsStorage(suiteName: "persist-test-suite")

        XCTAssertNotNil(storage, "UserDefaultsStorage(suiteName:) should not return `nil`")
    }

    func testUserDefaultsStorageGlobalSuiteNameInitialiser() {
        let storage = UserDefaultsStorage(suiteName: UserDefaults.globalDomain)

        XCTAssertNil(storage, "UserDefaultsStorage(suiteName:) should return `nil` for the global domain")
    }

    func testPersisterWithURL() throws {
        let persister = Persister<URL?>(key: "test", userDefaults: userDefaults)
        let url = URL(string: "http://example.com")!

        try persister.persist(url)
        XCTAssertEqual(try persister.retrieveValueOrThrow(), url)
    }

    func testPersisterWithBoolFalse() throws {
        let persister = Persister<Bool?>(key: "test", userDefaults: userDefaults)
        let bool = false

        try persister.persist(bool)
        XCTAssertEqual(try persister.retrieveValueOrThrow(), bool)
    }

    func testPersisterWithBoolTrue() throws {
        let persister = Persister<Bool?>(key: "test", userDefaults: userDefaults)
        let bool = true

        try persister.persist(bool)
        XCTAssertEqual(try persister.retrieveValueOrThrow(), bool)
    }

    func testPersisterWithInt() throws {
        let persister = Persister<Int?>(key: "test", userDefaults: userDefaults)
        let int = 0

        try persister.persist(int)
        XCTAssertEqual(try persister.retrieveValueOrThrow(), int)
    }

    func testPersisterWithDouble() throws {
        let persister = Persister<Double?>(key: "test", userDefaults: userDefaults)
        let double = 1.23

        try persister.persist(double)
        XCTAssertEqual(try persister.retrieveValueOrThrow(), double)
    }

    func testPersisterWithFloat() throws {
        let persister = Persister<Float?>(key: "test", userDefaults: userDefaults)
        let float: Float = 1.23

        try persister.persist(float)
        XCTAssertEqual(try persister.retrieveValueOrThrow()!, float, accuracy: 0.1)
    }

    func testPersisterWithArray() throws {
        let persister = Persister<[Int]?>(key: "test", userDefaults: userDefaults)
        let array = [1, 2, 0, 6]

        try persister.persist(array)
        XCTAssertEqual(try persister.retrieveValueOrThrow(), array)
    }

    func testPersisterWithDictionary() throws {
        let persister = Persister<[String: [Int]]?>(key: "test", userDefaults: userDefaults)
        let dictionary = [
            "foo": [1, 2, 0, 6],
            "bar": [0, 4, 7],
        ]

        try persister.persist(dictionary)
        XCTAssertEqual(try persister.retrieveValueOrThrow(), dictionary)
    }

    func testRetrieveValueOfDifferentType() {
        let key = "key"
        let actualValue = "test"
        let persister = Persister<Int?>(key: key, userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = persister.addUpdateListener() { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch newValue {
            case .failure(PersistenceError.unexpectedValueType(let value, let expected)):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int.self)
            default:
                XCTFail()
            }
        }
        _ = cancellable

        userDefaults.set(actualValue, forKey: "key")

        XCTAssertThrowsError(try persister.retrieveValueOrThrow(), "Retrieving a value with a different type should throw") { error in
            switch error {
            case PersistenceError.unexpectedValueType(let value, let expected):
                XCTAssertEqual(value as? String, actualValue)
                XCTAssert(expected == Int.self)
            default:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.1)
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

    func testRemoveValue() {
        let url = URL(string: "http://example.com")!
        let storage = UserDefaultsStorage(userDefaults: userDefaults)
        storage.storeValue(.url(url), key: "key")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = storage.addUpdateListener(forKey: "key") { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertNil(newValue, "Value passed to update listener should be nil for removed values")
        }
        _ = cancellable

        storage.removeValue(for: "key")

        XCTAssertNil(storage.retrieveValue(for: "key"))
        XCTAssertNil(userDefaults.object(forKey: "key"))

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
                _bar = Persisted<Bar?>(key: "bar", userDefaults: userDefaults, transformer: JSONTransformer())
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

        let persister = Persister<String?>(key: "test", userDefaults: userDefaults)
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
        let persister = Persister<String?>(key: key, userDefaults: userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let updateListenerCancellable = persister.addUpdateListener() { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update, .persisted(setValue))
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
                case .success(let update):
                    XCTAssertEqual(update, .persisted(setValue))
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
