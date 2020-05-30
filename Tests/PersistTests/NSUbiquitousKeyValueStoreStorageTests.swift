#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Foundation
@testable import Persist

final class NSUbiquitousKeyValueStoreStorageTests: XCTestCase {

    private let nsUbiquitousKeyValueStoreStorage = NSUbiquitousKeyValueStoreStorage.default

    func testPersistedNSUbiquitousKeyValueStoreAPI() {
        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default)
        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default)

        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStore: .default)
        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default)

        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer())
        _ = Persisted<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default, transformer: MockTransformer())

        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer())
        _ = Persisted<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default, transformer: MockTransformer())
    }

    func testPersisterNSUbiquitousKeyValueStoreAPI() {
        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default)
        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default)

        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStore: .default)
        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default)

        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer())
        _ = Persister<Double>(key: "test", storedBy: NSUbiquitousKeyValueStoreStorage.default, transformer: MockTransformer())

        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer())
        _ = Persister<Double>(key: "test", nsUbiquitousKeyValueStoreStorage: .default, transformer: MockTransformer())
    }

    func testStoredInUbiquitousKeyValueStore() {
        class Foo {
            @StoredInNSUbiquitousKeyValueStore
            var bar: String?

            init(nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage) {
                _bar = StoredInNSUbiquitousKeyValueStore(
                    key: "foo-bar",
                    storedBy: nsUbiquitousKeyValueStoreStorage
                )
            }
        }

        let foo = Foo(nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        foo.bar = "new-value"
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.string(forKey: "foo-bar"), "new-value")
    }

    func testStoringStrings() {
        let key = "key"
        let value = "test"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, .string(value), "Value passed to update listener should be new value")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.storeValue(.string(value), key: key)

        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.string(forKey: key), value, "String should be stored as strings")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), .string(value))

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
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

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
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: key) { newValue in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(newValue, ubiquitousKeyValueStoreValue, "Value passed to update listener should be new value")
        }
        _ = cancellable

        nsUbiquitousKeyValueStoreStorage.storeValue(ubiquitousKeyValueStoreValue, key: key)

        XCTAssertNotNil(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.dictionary(forKey: key), "Dictionaries should be stored as dictionaries")
        XCTAssertEqual(nsUbiquitousKeyValueStoreStorage.retrieveValue(for: key), ubiquitousKeyValueStoreValue)

        waitForExpectations(timeout: 0.1)
    }

    func testStoringTransformedValues() {
        struct Bar: Codable, Equatable {
            var baz: String
        }

        class Foo {
            @Persisted
            var bar: Bar?

            init(nsUbiquitousKeyValueStoreStorage: NSUbiquitousKeyValueStoreStorage) {
                _bar = Persisted(
                    key: "bar",
                    storedBy: nsUbiquitousKeyValueStoreStorage,
                    transformer: JSONTransformer()
                )
            }
        }

        let bar = Bar(baz: "new-value")
        let foo = Foo(nsUbiquitousKeyValueStoreStorage: nsUbiquitousKeyValueStoreStorage)
        foo.bar = bar
        XCTAssertNotNil(nsUbiquitousKeyValueStoreStorage.nsUbiquitousKeyValueStore.data(forKey: "bar"), "Should store transformed value")
        XCTAssertEqual(foo.bar, bar, "Should return untransformed value")
    }

    func testUpdateListenerWithStorageFunction() {
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { _ in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = cancellable
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("test"), key: "test")

        waitForExpectations(timeout: 1)
    }

    func testUpdateListenerFromNotification() {
        nsUbiquitousKeyValueStoreStorage.storeValue(.string("initial-value"), key: "test")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        callsUpdateListenerExpectation.assertForOverFulfill = true

        let updatedValue = "updated-value"
        let cancellable = nsUbiquitousKeyValueStoreStorage.addUpdateListener(forKey: "test") { update in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual(update, .string(updatedValue), "New value should be retrieved and passed to update listeners")
        }
        _ = cancellable

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

    func testPersisterUpdateListenerUpdateViaPersister() throws {
        let key = "test"
        let setValue = "value"
        let persister = Persister<String>(key: key, storedBy: nsUbiquitousKeyValueStoreStorage)

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
