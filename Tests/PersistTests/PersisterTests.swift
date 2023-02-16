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

    func testCachingValueAfterPersisting() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String>())
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true
        )
        let storedValue = "new-value"
        try persister.persist(storedValue)

        XCTAssertEqual(persister.retrieveValue(), storedValue, "Stored value should be returned when cached")
        XCTAssertEqual(storage.retrieveValueCallCount, 0, "Persister should not retrieve value from storage when value is cached")
    }

    func testCachingValueAfterPersistingThrowingAPI() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String>())
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true
        )
        let storedValue = "new-value"
        try persister.persist(storedValue)

        XCTAssertEqual(try persister.retrieveValueOrThrow(), storedValue, "Stored value should be returned when cached")
        XCTAssertEqual(storage.retrieveValueCallCount, 0, "Persister should not retrieve value from storage when value is cached")
    }

    func testCachingValueAfterDefaultValueIsUsed() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String?>())
        let defaultValue = "default-value"
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true,
            defaultValue: defaultValue
        )

        // Populate the stored value with the default value
        _ = persister.retrieveValue()

        XCTAssertEqual(persister.retrieveValue(), defaultValue, "Default value should be returned when cache is empty")
        XCTAssertEqual(storage.retrieveValueCallCount, 1, "Persister should retrieve value once from storage when default value is cached")
    }

    func testCachingValueAfterDefaultValueIsUsedThrowingAPI() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String?>())
        let defaultValue = "default-value"
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true,
            defaultValue: defaultValue
        )

        // Populate the stored value with the default value
        _ = persister.retrieveValue()

        XCTAssertEqual(try persister.retrieveValueOrThrow(), defaultValue, "Default value should be returned when cache is empty")
        XCTAssertEqual(storage.retrieveValueCallCount, 1, "Persister should retrieve value once from storage when default value is cached")
    }

    func testCachingValueAfterStorageUpdates() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String>())
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true
        )
        let storedValue = "new-value"
        // Storage will notify the persister, which should then cache the value.
        try storage.storeValue(storedValue, key: "test")

        XCTAssertEqual(persister.retrieveValue(), storedValue, "Stored value should be returned when cached")
        XCTAssertEqual(try persister.retrieveValueOrThrow(), storedValue, "Stored value should be returned when cached")
        XCTAssertEqual(storage.retrieveValueCallCount, 0, "Persister should not retrieve value from storage when value is cached")
    }

    func testForcingCacheInvalidation() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String>())
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true
        )
        let storedValue = "new-value"
        try persister.persist(storedValue)

        XCTAssertEqual(persister.retrieveValue(revalidateCache: true), storedValue, "Stored value should be returned when cache is invalidated")
        XCTAssertEqual(try persister.retrieveValueOrThrow(revalidateCache: true), storedValue, "Stored value should be returned when cache is invalidated")
        XCTAssertEqual(storage.retrieveValueCallCount, 2, "Persister should retrieve value from storage once for every call invalidating the cache")
    }

    func testCacheAfterValueIsRemoved() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String>())
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true
        )
        let storedValue = "new-value"
        try persister.persist(storedValue)
        try persister.removeValue()

        XCTAssertNil(persister.retrieveValue(), "Cached value should be removed when stored value is removed")
        XCTAssertNil(try persister.retrieveValueOrThrow(), "Cached value should be removed when stored value is removed")
        XCTAssertEqual(storage.retrieveValueCallCount, 0, "Persister should not retrieve value from storage after value has been removed")
        XCTAssertEqual(storage.removeValueCallCount, 1, "Persister should remove value from storage when cache is used")
    }

    func testCacheAfterValueIsRemovedWithDefaultValue() throws {
        let storage = SpyStorage(backingStorage: InMemoryStorage<String>())
        let storedValue = "new-value"
        try storage.storeValue(storedValue, key: "test")

        let defaultValue = "default-value"
        let persister = Persister<String?>(
            key: "test",
            storedBy: storage,
            cacheValue: true,
            defaultValue: defaultValue
        )

        try persister.removeValue()

        XCTAssertEqual(persister.retrieveValue(), defaultValue, "Default value should be return when stored value is removed and cache is used")
        XCTAssertEqual(try persister.retrieveValueOrThrow(), defaultValue, "Default value should be return when stored value is removed and cache is used")
        XCTAssertEqual(storage.retrieveValueCallCount, 0, "Persister should not retrieve value from storage after value has been removed and default value is provided")
        XCTAssertEqual(storage.removeValueCallCount, 1, "Persister should remove value from storage when cache is used")
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

    /// Prior to 1.3.0 subjects (which are exposed as publishers) were created
    /// lazily when the first update occurred _or_ one of the publisher
    /// properties was accessed.
    ///
    /// This could crash if multiple updates were sent across multiple queues
    /// and the properties had not yet been created.
    ///
    /// This would crash quite consistently when it's the only test being run.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testPersistingValueAcrossQueuesWithoutPublishers() throws {
        let storage = InMemoryStorage<Int>()
        let persister = Persister(key: "test", storedBy: storage, defaultValue: nil)

        let updatesCount = 10_000

        let persistsValueExpectation = expectation(description: "Persists value")
        persistsValueExpectation.expectedFulfillmentCount = updatesCount
        DispatchQueue.concurrentPerform(iterations: updatesCount) { index in
            try? persister.persist(index)
            persistsValueExpectation.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    /// This is the same as ``testPersistingValueAcrossQueuesWithoutPublishers``
    /// but with both publishers created prior to sending an update. This is
    /// more of a test that the publishers support access across threads, which
    /// is explicitly supported according to
    /// https://forums.swift.org/t/thread-safety-for-combine-publishers/29491/13
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testPersistingValueAcrossQueuesWithPublishers() throws {
        let storage = InMemoryStorage<Int>()
        let persister = Persister(key: "test", storedBy: storage, defaultValue: nil)

        let updatesCount = 10_000

        let notifiesPublisherExpectation = expectation(description: "Calls update listener")
        notifiesPublisherExpectation.expectedFulfillmentCount = updatesCount
        let publisherSubscription = persister.publisher.dropFirst().sink { _ in
            notifiesPublisherExpectation.fulfill()
        }

        let notifiesUpdatesPublisherExpectation = expectation(description: "Calls update listener")
        notifiesUpdatesPublisherExpectation.expectedFulfillmentCount = updatesCount
        let updatesPublisherSubscription = persister.updatesPublisher.sink { _ in
            notifiesUpdatesPublisherExpectation.fulfill()
        }

        DispatchQueue.concurrentPerform(iterations: updatesCount) { index in
            try? persister.persist(index)
        }

        waitForExpectations(timeout: 3, handler: nil)

        _ = publisherSubscription
        _ = updatesPublisherSubscription
    }
    #endif

}
#endif
