//#if canImport(SwiftUI) && canImport(Combine) && !os(watchOS)
//import Combine
//import XCTest
//@testable import Persist
//
//@available(iOS 13, tvOS 13, watchOS 6, macOS 10.15, *)
//final class PersistStorageTests: XCTestCase {
//    func testPersistStorage() throws {
//        let storage = InMemoryStorage<String>()
//        let persister = Persister(key: "key", storedBy: storage)
//        let persistStorage = PersistStorage(persister: persister)
//        let binding = persistStorage.projectedValue
//
//        XCTAssertTrue(persistStorage.persister === persister, "Should provide persister passed to initialiser")
//
//        let persistedValue = "stored-value"
//        try persister.persist(persistedValue)
//        XCTAssertEqual(persistStorage.wrappedValue, persistedValue, "Wrapped value should return persisted value")
//        XCTAssertEqual(binding.wrappedValue, persistedValue, "Binding should return persisted value")
//
//        let valueSetByWrappedValue = "wrapped-value"
//        persistStorage.wrappedValue = valueSetByWrappedValue
//        XCTAssertEqual(persister.retrieveValue(), valueSetByWrappedValue, "Setting value with `wrappedValue` should persist value")
//
//        let valueSetByBinding = "binding-value"
//        binding.wrappedValue = valueSetByBinding
//        XCTAssertEqual(persister.retrieveValue(), valueSetByBinding, "Setting value with binding should persist value")
//    }
//}
//#endif
