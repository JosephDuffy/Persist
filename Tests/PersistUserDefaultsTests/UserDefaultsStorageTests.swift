#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import PersistUserDefaults

final class UserDefaultsStorageTests: XCTestCase {

    private let userDefaultsStorage = UserDefaultsStorage(suiteName: "test-suite")!

    override func tearDown() {
        let userDefaults = userDefaultsStorage.userDefaults
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testUserDefaultsStorageGlobalSuiteNameInitialiser() {
        let storage = UserDefaultsStorage(suiteName: UserDefaults.globalDomain)

        XCTAssertNil(storage, "UserDefaultsStorage(suiteName:) should return `nil` for the global domain")
    }

    func testStoringFalseBool() throws {
        let key = "key"
        let value = false

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .int(0), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.bool(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.bool(forKey: key), value, "Bools should be retreivable from NSUbiquitousKeyValueStore as bools")
        // Bools are stored within `NSUbiquitousKeyValueStore` as Int.
        // `StorableInUserDefaultsTransformer` converts this to a `Bool` as required.
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .int(0))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringTrueBool() throws {
        let key = "key"
        let value = true

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .int(1), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.bool(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.bool(forKey: key), value, "Bools should be retreivable from NSUbiquitousKeyValueStore as bools")
        // Bools are stored within `NSUbiquitousKeyValueStore` as Int.
        // `StorableInUserDefaultsTransformer` converts this to a `Bool` as required.
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .int(1))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringURLs() {
        let key = "key"
        let value = URL(string: "http://example.com/")!

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .url(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.url(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.url(forKey: key), value, "URLs should be stored as URLs")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .url(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .string(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.string(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.string(forKey: key), value, "String should be stored as strings")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .string(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringData() {
        let key = "key"
        let value = Data()

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .data(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.data(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.data(forKey: key), value, "Data should be stored as data")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .data(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDouble() {
        let key = "key"
        let value = 123.45 as Double

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .double(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.double(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.double(forKey: key), value, "Double should be stored as double")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .double(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDoubleWithoutFractionalDigit() {
        let key = "key"
        let value = 123 as Double

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .double(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.double(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.double(forKey: key), value, "Double should be stored as double")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .double(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringFloat() {
        let key = "key"
        let value = 123.45 as Float

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .float(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.float(value), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.float(forKey: key), value, "Float should be stored as float")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .float(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringFloatWithoutFractionalDigit() {
        let key = "key"
        let value = 22 as Float

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .number(value as NSNumber), "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(.number(value as NSNumber), key: key)

        XCTAssertEqual(userDefaultsStorage.userDefaults.float(forKey: key), value, "Float should be stored as float")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), .number(value as NSNumber))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringArray() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = UserDefaultsValue.array([
            .array([.int(1), .int(2), .int(3)]),
            .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(userDefaultsStorage.userDefaults.array(forKey: key), "Arrays should be stored as arrays")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDictionary() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = UserDefaultsValue.dictionary([
            "foo": .array([.int(1), .int(2), .int(3)]),
            "bar": .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            "baz": .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = userDefaultsStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = subscription

        userDefaultsStorage.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(userDefaultsStorage.userDefaults.dictionary(forKey: key), "Dictionaries should be stored as dictionaries")
        XCTAssertEqual(userDefaultsStorage.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testUpdateListenerWithKeyWithDot() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let subscription = userDefaultsStorage.addUpdateListener(forKey: "test.test") { value in
            callsUpdateListenerExpectation.fulfill()
            XCTAssert(value == .some(.string("test")))
        }
        _ = subscription
        userDefaultsStorage.storeValue(.string("test"), key: "test.test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerWithStorageFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let subscription = userDefaultsStorage.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription
        userDefaultsStorage.storeValue(.string("test"), key: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerNewValueFromNotification() {
        userDefaultsStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let updatedValue = "updated-value"
        let subscription = userDefaultsStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, .string(updatedValue), "New value should be retrieved and passed to update listeners")
        }
        _ = subscription

        userDefaultsStorage.userDefaults.set(updatedValue, forKey: "test")
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: userDefaultsStorage.userDefaults,
            userInfo: [
                NSUbiquitousKeyValueStoreChangedKeysKey: ["test"],
            ]
        )

        waitForExpectations(timeout: 1)
    }

    func testUpdateViaUnderlyingNSUbiquitousKeyValueStoreStorage() {
        userDefaultsStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let subscription = userDefaultsStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, nil, "New value should be retrieved and passed to update listeners")
        }
        _ = subscription

        userDefaultsStorage.userDefaults.removeObject(forKey: "test")
        XCTAssertNil(userDefaultsStorage.retrieveValue(for: "test"))
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: userDefaultsStorage.userDefaults,
            userInfo: [
                NSUbiquitousKeyValueStoreChangedKeysKey: ["test"],
            ]
        )

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerDeletedViaStorage() {
        userDefaultsStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let subscription = userDefaultsStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, nil, "New value should be retrieved and passed to update listeners")
        }
        _ = subscription

        userDefaultsStorage.removeValue(for: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerForDifferentKeyChange() {
        userDefaultsStorage.storeValue(.string("initial-value"), key: "test")
        userDefaultsStorage.storeValue(.string("initial-value"), key: "test2")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.isInverted = true
        let subscription = userDefaultsStorage.addUpdateListener(forKey: "test") { update in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        userDefaultsStorage.removeValue(for: "test2")

        waitForExpectations(timeout: 1)
    }

    func testUserDefaultsArrayDictionaryStorage() throws {
        let storage = UserDefaultsArrayDictionaryStorage(arrayKey: "TestArray", arrayIndex: 0, userDefaults: userDefaultsStorage.userDefaults)

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.isInverted = true
        let subscription = storage.addUpdateListener(forKey: "foo") { update in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        try storage.storeValue(.string("123"), key: "foo")

        waitForExpectations(timeout: 1)
    }

}
#endif
