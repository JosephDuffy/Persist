#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Foundation
@testable import Persist

final class UbiquitousKeyValueStoreValueStorageTests: XCTestCase {

    private let ubiquitousKeyValueStore = UbiquitousKeyValueStore.default

    func testStoredInUbiquitousKeyValueStore() {
        class Foo {
            @StoredInUbiquitousKeyValueStore
            var bar: String?

            init(ubiquitousKeyValueStore: UbiquitousKeyValueStore) {
                _bar = StoredInUbiquitousKeyValueStore(
                    key: "foo-bar",
                    storedBy: ubiquitousKeyValueStore
                )
            }
        }

        let foo = Foo(ubiquitousKeyValueStore: ubiquitousKeyValueStore)
        foo.bar = "new-value"
        XCTAssertEqual(ubiquitousKeyValueStore.nsUbiquitousKeyValueStore.string(forKey: "foo-bar"), "new-value")
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = ubiquitousKeyValueStore.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .string(value), "Value passed to update listener should be new value")
        }
        _ = cancellable

        ubiquitousKeyValueStore.storeValue(.string(value), key: key)

        XCTAssertEqual(ubiquitousKeyValueStore.nsUbiquitousKeyValueStore.string(forKey: key), value, "String should be stored as strings")
        XCTAssertEqual(ubiquitousKeyValueStore.retrieveValue(for: key), .string(value))

        waitForExpectations(timeout: 0.1)
    }

    func testStoringArray() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = UbiquitousKeyValueStoreValue.array([
            .array([.int64(1), .int64(2), .int64(3)]),
            .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = ubiquitousKeyValueStore.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        ubiquitousKeyValueStore.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(ubiquitousKeyValueStore.nsUbiquitousKeyValueStore.array(forKey: key), "Arrays should be stored as arrays")
        XCTAssertEqual(ubiquitousKeyValueStore.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringDictionary() {
        let key = "key"
        let ubiquitousKeyValueStoreValue = UbiquitousKeyValueStoreValue.dictionary([
            "foo": .array([.int64(1), .int64(2), .int64(3)]),
            "bar": .dictionary([
                "embedded-baz": .double(123.45),
            ]),
            "baz": .string("hello world"),
        ])

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = ubiquitousKeyValueStore.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        ubiquitousKeyValueStore.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(ubiquitousKeyValueStore.nsUbiquitousKeyValueStore.dictionary(forKey: key), "Dictionaries should be stored as dictionaries")
        XCTAssertEqual(ubiquitousKeyValueStore.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringTransformedValues() {
        struct Bar: Codable, Equatable {
            var baz: String
        }

        class Foo {
            @Persisted
            var bar: Bar?

            init(ubiquitousKeyValueStore: UbiquitousKeyValueStore) {
                _bar = Persisted(
                    key: "bar",
                    storedBy: ubiquitousKeyValueStore,
                    transformer: JSONTransformer()
                )
            }
        }

        let bar = Bar(baz: "new-value")
        let foo = Foo(ubiquitousKeyValueStore: ubiquitousKeyValueStore)
        foo.bar = bar
        XCTAssertNotNil(ubiquitousKeyValueStore.nsUbiquitousKeyValueStore.data(forKey: "bar"), "Should store transformed value")
        XCTAssertEqual(foo.bar, bar, "Should return untransformed value")
    }

    func testUpdateListenerWithStorageFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = ubiquitousKeyValueStore.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        ubiquitousKeyValueStore.storeValue(.string("test"), key: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerFromNotification() {
        ubiquitousKeyValueStore.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let updatedValue = "updated-value"
        let cancellable = ubiquitousKeyValueStore.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, .string(updatedValue), "New value should be retrieved and passed to update listeners")
        }
        _ = cancellable

        ubiquitousKeyValueStore.nsUbiquitousKeyValueStore.set(updatedValue, forKey: "test")
        NotificationCenter.default.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitousKeyValueStore.nsUbiquitousKeyValueStore,
            userInfo: [
                NSUbiquitousKeyValueStoreChangedKeysKey: ["test"],
            ]
        )

        waitForExpectations(timeout: 1)
    }

    func testPersisterUpdateListenerUpdateViaPersister() throws {
        let key = "test"
        let setValue = "value"
        let persister = Persister<String>(key: key, storedBy: ubiquitousKeyValueStore)

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
