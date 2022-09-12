#if !os(watchOS)
import XCTest
@testable import Persist

final class PersisterTests: XCTestCase {

    func testStoringValueWithAnyStorageType() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let storage = InMemoryStorage<Any>()
        let defaultValue = StoredValue(property: "default")
        let persister = Persister<StoredValue>(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
                XCTAssertEqual(update.event.value, storedValue, "Event value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.persist(storedValue)
        XCTAssertEqual(persister.retrieveValue(), storedValue, "Should retrieve stored value")
        XCTAssertEqual(storage.retrieveValue(for: "test") as? StoredValue, storedValue, "Should store value in storage")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStoringValueWithSpecficStorageType() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
                XCTAssertEqual(update.event.value, storedValue, "Event value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.persist(storedValue)
        XCTAssertEqual(persister.retrieveValue(), storedValue, "Should retrieve stored value")
        XCTAssertEqual(storage.retrieveValue(for: "test"), storedValue, "Should store value in storage")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testStoringTransformedValue() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let storage = InMemoryStorage<Data>()
        let defaultValue = StoredValue(property: "default")
        let persister = Persister<StoredValue>(key: "test", storedBy: storage, transformer: JSONTransformer(), defaultValue: defaultValue)
        let storedValue = StoredValue(property: "value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the new, untransformed, value")
                XCTAssertEqual(update.event.value, storedValue, "Event value passed to update listener should be the new, untransformed, value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.persist(storedValue)
        XCTAssertNotNil(storage.retrieveValue(for: "test"), "Should store encoded data in storage")
        XCTAssertEqual(persister.retrieveValue(), storedValue, "Should return untransformed value")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRemovingValue() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        try persister.persist("stored-value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, defaultValue, "Value passed to update listener should be the default value")
                XCTAssertNil(update.event.value, "Event value passed to update listener should be `nil``")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.removeValue()
        XCTAssertNil(storage.retrieveValue(for: "test"), "Should remove value from storage")

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValue() throws {
        let storage = InMemoryStorage<String>()
        let persister = Persister<String?>(key: "test", storedBy: storage)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithDefault() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister<String?>(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        XCTAssert(persister.retrieveValue() == defaultValue, "Default value should be passed default value")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithAnyStorage() throws {
        let storage = InMemoryStorage<Any>()
        let persister = Persister<String?>(key: "test", storedBy: storage)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithAnyStorageWithDefault() throws {
        let storage = InMemoryStorage<Any>()
        let defaultValue = "default"
        let persister = Persister<String?>(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        XCTAssert(persister.retrieveValue() == defaultValue, "Default value should be passed default value")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithTransformer() throws {
        let storage = InMemoryStorage<String>()
        let persister = Persister<String?>(key: "test", storedBy: storage, transformer: MockTransformer())
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOptionalValueWithAnyStorageAnyTransformer() throws {
        let storage = InMemoryStorage<Any>()
        let persister = Persister<String?>(key: "test", storedBy: storage, transformer: MockTransformer())
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be new value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be new value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        XCTAssertNil(persister.retrieveValue(), "Default value should be `nil`")
        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdateListenersAcrossThreads() throws {
        let storage = InMemoryStorage<Any>()
        var persister: Persister? = Persister<String?>(key: "test", storedBy: storage)
        var cancellables: Set<AnyCancellable> = []
        let cancellablesLock = NSLock()
        func modifyCancellables(_ modify: (_ cancellables: inout Set<AnyCancellable>) -> Void) {
            cancellablesLock.lock()
            modify(&cancellables)
            cancellablesLock.unlock()
        }

        let updateListenersAddedExpectation = expectation(description: "Adds all update listeners")
        updateListenersAddedExpectation.expectedFulfillmentCount = 10
        let updateListenersNotified = expectation(description: "Notifies all update listeners")
        updateListenersNotified.expectedFulfillmentCount = 10
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            let cancellable = persister?.addUpdateListener({ _ in
                updateListenersNotified.fulfill()
            })
            updateListenersAddedExpectation.fulfill()

            if let cancellable = cancellable {
                modifyCancellables { cancellables in
                    cancellables.insert(cancellable)
                }
            }
        }
        try persister?.persist("new-value")

        let deallocAllUpdateListenersExpectation = expectation(description: "Deallocs all update listeners")
        deallocAllUpdateListenersExpectation.expectedFulfillmentCount = 10
        DispatchQueue.concurrentPerform(iterations: 5) { index in
            modifyCancellables { cancellables in
                cancellables.removeFirst()
            }

            deallocAllUpdateListenersExpectation.fulfill()
        }

        persister = nil
        DispatchQueue.concurrentPerform(iterations: 5) { index in
            modifyCancellables { cancellables in
                cancellables.removeFirst()
            }

            deallocAllUpdateListenersExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testPersistingValuesAcrossThreads() throws {
        let storage = InMemoryStorage<Any>()
        let persister = Persister<String?>(key: "test", storedBy: storage)
        var cancellables: Set<AnyCancellable> = []
        let cancellablesLock = NSLock()
        func modifyCancellables(_ modify: (_ cancellables: inout Set<AnyCancellable>) -> Void) {
            cancellablesLock.lock()
            modify(&cancellables)
            cancellablesLock.unlock()
        }

        let updateListenersAddedExpectation = expectation(description: "Adds all update listeners")
        updateListenersAddedExpectation.expectedFulfillmentCount = 10
        let updateListenersNotified = expectation(description: "Notifies all update listeners")
        updateListenersNotified.expectedFulfillmentCount = 100
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            let cancellable = persister.addUpdateListener({ _ in
                updateListenersNotified.fulfill()
            })
            updateListenersAddedExpectation.fulfill()

            modifyCancellables { cancellables in
                cancellables.insert(cancellable)
            }
        }

        DispatchQueue.concurrentPerform(iterations: 10) { index in
            try? persister.persist("new-value-\(index)")
        }

        waitForExpectations(timeout: 1)
    }

    func testAccessingDefaultValueAcrossThreads() throws {
        let storage = InMemoryStorage<Any>()
        let requestsDefaultValue = expectation(description: "Requests default value")
        let persister = Persister<String>(
            key: "test",
            storedBy: storage,
            defaultValue: { () -> String in
                requestsDefaultValue.fulfill()
                return "default-value"
            }()
        )

        let updateListenersNotified = expectation(description: "Requests value")
        updateListenersNotified.expectedFulfillmentCount = 10
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            _ = persister.retrieveValue()
            updateListenersNotified.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    /// Tests that new subscribers can be added in response to a value being
    /// updated.
    ///
    /// This test aims to validate that the locks used to ensure thread-safety
    /// don't cause a deadlock in this situation.
    func testAddingSubscriberInsideUpdateClosure() throws {
        let storage = InMemoryStorage<String>()
        let persister = Persister(key: "test", storedBy: storage, defaultValue: "default")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let newSubscriptionIsCreatedExpectation = expectation(description: "New subscription is created")
        let subscription = persister.addUpdateListener { [weak persister] _ in
            callsUpdateListenerExpectation.fulfill()

            guard let persister = persister else {
                XCTFail("Persister should be non-nil")
                return
            }
            let newSubscription = persister.addUpdateListener { _ in }
            newSubscriptionIsCreatedExpectation.fulfill()
            _ = newSubscription
        }
        _ = subscription

        try persister.persist("new-value")

        waitForExpectations(timeout: 1)
    }

    #if canImport(Combine)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testSettingValueNotifiesUpdatesPublisher() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.updatesPublisher.sink { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, storedValue, "Value passed to update listener should be the stored value")
                XCTAssert(update.event.value == storedValue, "Event value passed to update listener should be stored value")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testRemovingValueNotifiesUpdatesPublisher() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        try persister.persist("stored-value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.updatesPublisher.sink { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, defaultValue, "Value passed to update listener should be the default value")
                XCTAssertNil(update.event.value, "Event value passed to update listener should be `nil``")
            case .failure(let error):
                XCTFail("Update listener should be notified of a success. Got error: \(error)")
            }
        }
        _ = subscription

        try persister.removeValue()

        waitForExpectations(timeout: 1, handler: nil)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testSettingValueNotifiesPublisher() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        let storedValue = "stored-value"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.publisher.dropFirst().sink { newValue in
            XCTAssertEqual(newValue, storedValue, "Value passed to update listener should be the stored value")
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        try persister.persist(storedValue)

        waitForExpectations(timeout: 1, handler: nil)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testRemovingValueNotifiesPublisher() throws {
        let storage = InMemoryStorage<String>()
        let defaultValue = "default"
        let persister = Persister(key: "test", storedBy: storage, defaultValue: defaultValue)
        try persister.persist("stored-value")

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = persister.publisher.dropFirst().sink { newValue in
            XCTAssertEqual(newValue, defaultValue, "Value passed to update listener should be the default value")
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        try persister.removeValue()

        waitForExpectations(timeout: 1, handler: nil)
    }
    #endif

}
#endif
