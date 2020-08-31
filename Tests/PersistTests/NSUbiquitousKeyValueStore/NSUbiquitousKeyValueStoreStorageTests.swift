#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Foundation
@testable import Persist

final class NSUbiquitousKeyValueStoreStorageTests: XCTestCase {

    private let nsUbiquitousKeyValueStoreStorage = NSUbiquitousKeyValueStoreStorage(nsUbiquitousKeyValueStore: .default)

    override func tearDown() {
        let nsUbiquitousKeyValueStore = nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore
        nsUbiquitousKeyValueStore
            .dictionaryRepresentation
            .keys
            .forEach(nsUbiquitousKeyValueStore.removeObject(forKey:))
    }

    func testStoringFalseBool() throws {
        let key = "key"
        let value = false

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .bool(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(.bool(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.bool(forKey: key), value, "Bools should be retreivable from NSUbiquitousKeyValueStore as bools")
        // Bools are stored within `NSUbiquitousKeyValueStore` as Int64.
        // `StorableInNSUbiquitousKeyValueStoreTransformer` converts this to a `Bool` as required.
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .int64(0))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringTrueBool() throws {
        let key = "key"
        let value = true

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .bool(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(.bool(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.bool(forKey: key), value, "Bools should be retreivable from NSUbiquitousKeyValueStore as bools")
        // Bools are stored within `NSUbiquitousKeyValueStore` as Int64.
        // `StorableInNSUbiquitousKeyValueStoreTransformer` converts this to a `Bool` as required.
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .int64(1))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .string(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(.string(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.string(forKey: key), value, "String should be stored as strings")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .string(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringData() {
        let key = "key"
        let value = Data()

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .data(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(.data(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.data(forKey: key), value, "Data should be stored as data")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .data(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDouble() {
        let key = "key"
        let value = 123.45 as Double

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .double(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(.double(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.double(forKey: key), value, "Double should be stored as double")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .double(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDoubleWithoutFractionalDigit() {
        let key = "key"
        let value = 123 as Double

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .double(value), "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(.double(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.double(forKey: key), value, "Double should be stored as double")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .double(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringArray() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue.array([
            .array([.int64(1), .int64(2), .int64(3)]),
            .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.array(forKey: key), "Arrays should be stored as arrays")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDictionary() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = NSUbiquitousKeyValueStoreValue.dictionary([
            "foo": .array([.int64(1), .int64(2), .int64(3)]),
            "bar": .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            "baz": .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.dictionary(forKey: key), "Dictionaries should be stored as dictionaries")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testUpdateListenerWithStorageFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("test"), key: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerNewValueFromNotification() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let updatedValue = "updated-value"
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, .string(updatedValue), "New value should be retrieved and passed to update listeners")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.set(updatedValue, forKey: "test")
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore,
            userInfo: [
                NSUbiquitousKeyValueStoreChangedKeysKey: ["test"],
            ]
        )

        waitForExpectations(timeout: 1)
    }

    func testUpdateViaUnderlyingNSUbiquitousKeyValueStoreStorage() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, nil, "New value should be retrieved and passed to update listeners")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.removeObject(forKey: "test")
        XCTAssertNil(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: "test"))
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore,
            userInfo: [
                NSUbiquitousKeyValueStoreChangedKeysKey: ["test"],
            ]
        )

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerDeletedViaStorage() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, nil, "New value should be retrieved and passed to update listeners")
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.removeValue(for: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerForDifferentKeyChange() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test2")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.isInverted = true
        let subscription = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        nsUbiquitousKeyValueStoreStorage.removeValue(for: "test2")

        waitForExpectations(timeout: 1)
    }

}
#endif
