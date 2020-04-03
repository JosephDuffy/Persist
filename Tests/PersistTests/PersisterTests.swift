import XCTest
@testable import Persist

final class PersisterTests: XCTestCase {

    func testStoringTransformedValue() throws {
        struct StoredValue: Codable, Equatable {
            let property: String
        }
        let persister = Persister<StoredValue?>(key: "test", storedBy: InMemoryStorage(), transformer: JSONTransformer(), lock: UnfairLock())
        let storedValue = StoredValue(property: "value")
        try persister.persist(storedValue)
        XCTAssertNotNil(try persister.storage.retrieveValue(for: "test") as Data?, "Should store encoded data in storage")
        XCTAssertEqual(try persister.retrieveValue(), storedValue, "Should return untransformed value")
    }

    func testFiarLockAccessFromMultipleThreads() throws {
        let key = "key"
        let initialValue = "initial"
        let firstSetValue = "set1"
        let secondSetValue = "set2"
        let storage = SlowStorage()
        let persister = Persister<String>(key: key, storedBy: storage, lock: FairLock())
        try persister.persist(initialValue)
        storage.storeDelay = 100_000 // 1/10 second

        let setQueue = DispatchQueue(label: "set queue")
        let setQueue2 = DispatchQueue(label: "set queue2")
        let firstAfterSetReadQueue = DispatchQueue(label: "first after set read queue")
        let secondAfterSetReadQueue = DispatchQueue(label: "second after set read queue")

        let setValue1Expectation = expectation(description: "queue set value 1")
        setQueue.async {
            setValue1Expectation.fulfill()
            try! persister.persist(firstSetValue)
        }
        usleep(100)

        let firstAfterSetReadExpectation = expectation(description: "retrieveValue returns value passed to `persist` called before `retrieveValue`")
        let readValue1Expectation = expectation(description: "queue read value 1")
        firstAfterSetReadQueue.async {
            defer {
                firstAfterSetReadExpectation.fulfill()
            }

            readValue1Expectation.fulfill()
            let value = try! persister.retrieveValue()
            XCTAssertEqual(value, firstSetValue)
        }
        usleep(100)

        let setValue2Expectation = expectation(description: "queue set value 2")
        setQueue2.async {

            setValue2Expectation.fulfill()
            try! persister.persist(secondSetValue)
        }
        usleep(100)

        let secondAfterSetReadExpectation = expectation(description: "retrieveValue returns value passed to `persist` called before `retrieveValue`")
        let readValue2Expectation = expectation(description: "queue read value 2")
        secondAfterSetReadQueue.async {
            defer {
                secondAfterSetReadExpectation.fulfill()
            }

            readValue2Expectation.fulfill()
            let value = try! persister.retrieveValue()
            XCTAssertEqual(value, secondSetValue)
        }

//        waitForExpectations(timeout: 3)
        wait(
            for: [
                setValue1Expectation,
                readValue1Expectation,
                setValue2Expectation,
                readValue2Expectation,
                firstAfterSetReadExpectation,
                secondAfterSetReadExpectation,
            ],
            timeout: 1,
            enforceOrder: true
        )
    }

}
