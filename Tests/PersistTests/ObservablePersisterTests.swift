//#if canImport(SwiftUI) && canImport(Combine) && !os(watchOS)
//import Combine
//import XCTest
//@testable import Persist
//
//@available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
//final class ObservablePersisterTests: XCTestCase {
//    func testSettingValueNotifiesPublisher() throws {
//        let storage = InMemoryStorage<String>()
//        let persister = Persister(key: "key", storedBy: storage)
//        let observablePersister = ObservablePersister(persister: persister)
//        let willChangePublisher = observablePersister.objectWillChange.eraseToAnyPublisher()
//        let callsPublisherExpectation = expectation(description: "Calls object will change publisher")
//
//        var cancellables: Set<Combine.AnyCancellable> = []
//        willChangePublisher.sink { _ in
//            callsPublisherExpectation.fulfill()
//        }.store(in: &cancellables)
//
//        try persister.persist("new-value")
//
//        waitForExpectations(timeout: 1)
//    }
//
//    func testPersistenceErrorDoesNothing() throws {
//        let storage = InMemoryStorage<String>()
//        let transformer = MockTransformer<String>()
//        let errorToThrow = NSError(domain: "tests", code: -1, userInfo: nil)
//        transformer.errorToThrow = errorToThrow
//        let persister = Persister(key: "key", storedBy: storage, transformer: transformer)
//        let observablePersister = ObservablePersister(persister: persister)
//        let willChangePublisher = observablePersister.objectWillChange.eraseToAnyPublisher()
//        let callsPublisherExpectation = expectation(description: "Calls object will change publisher")
//        callsPublisherExpectation.isInverted = true
//
//        var cancellables: Set<Combine.AnyCancellable> = []
//        willChangePublisher.sink { _ in
//            callsPublisherExpectation.fulfill()
//        }.store(in: &cancellables)
//
//        storage.storeValue("new-vale", key: "key")
//
//        waitForExpectations(timeout: 1)
//    }
//}
//#endif
