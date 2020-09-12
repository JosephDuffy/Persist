#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
@testable import PersistUserDefaults
import PersistCore

final class UserDefaultsMappedArrayStorageTests: XCTestCase {
    private let userDefaults = UserDefaults(suiteName: "test-suite")!

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testUpdatingMovedModel() throws {
        struct Model: StoredInUserDefaultsDictionary {
            let id: String

            @Persisted
            var property: String?

            let storage: UserDefaultsArrayDictionaryStorage

            init(storage: UserDefaultsArrayDictionaryStorage, id: String? = nil) throws {
                self.storage = storage

                _property = Persisted(key: "foo", storedBy: storage, transformer: StorableInUserDefaultsTransformer())

                if let id = id {
                    try storage.storeValue(.string(id), key: "id")
                    self.id = id
                } else {
                    self.id = try storage.retrieveValue(for: "id", ofType: String.self)
                }
            }
        }

        let storage = UserDefaultsMappedArrayStorage(userDefaults: userDefaults) { storage in
            try Model(storage: storage)
        }

        let dictionaryKey = "TestKey"

        let firstValue = try storage.createNewValue(forKey: dictionaryKey) { storage in
            try Model(storage: storage, id: UUID().uuidString)
        }

        let secondValue = try storage.createNewValue(forKey: dictionaryKey) { storage in
            try Model(storage: storage, id: UUID().uuidString)
        }

        let thirdValue = try storage.createNewValue(forKey: dictionaryKey) { storage in
            try Model(storage: storage, id: UUID().uuidString)
        }

        let setValue = "new-value"
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = secondValue.$property.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual((try? result.get())?.newValue, setValue, "Value passed to update listener should be new value")
        }
        _ = subscription

        try storage.storeValue([secondValue, firstValue, thirdValue], key: dictionaryKey)

        firstValue.property = "different-value"
        secondValue.property = setValue

        XCTAssertEqual(secondValue.property, setValue)
        waitForExpectations(timeout: 1)
    }

    func testArrayPropertyUpdates() throws {
        struct Model: StoredInUserDefaultsDictionary {
            let id: String

            @Persisted
            var property: String?

            let storage: UserDefaultsArrayDictionaryStorage

            init(storage: UserDefaultsArrayDictionaryStorage, id: String? = nil) throws {
                self.storage = storage

                _property = Persisted(key: "foo", storedBy: storage, transformer: StorableInUserDefaultsTransformer())

                if let id = id {
                    try storage.storeValue(.string(id), key: "id")
                    self.id = id
                } else {
                    self.id = try storage.retrieveValue(for: "id", ofType: String.self)
                }
            }
        }

        struct Wrapper {
            @Persisted
            var properties: [Model]

            private let storage: UserDefaultsMappedArrayStorage<Model>

            init(storage: UserDefaultsMappedArrayStorage<Model>) {
                _properties = Persisted(key: "TestKey", storedBy: storage, defaultValue: [])
                self.storage = storage
            }

            public func addProperty() throws -> Model {
                return try storage.createNewValue(forKey: "TestKey") { storage in
                    try Model(storage: storage, id: UUID().uuidString)
                }
            }
        }

        let storage = UserDefaultsMappedArrayStorage(userDefaults: userDefaults) { storage in
            try Model(storage: storage)
        }

        let wrapper = Wrapper(storage: storage)

        let firstValue = try wrapper.addProperty()
        let secondValue = try wrapper.addProperty()
        let thirdValue = try wrapper.addProperty()

        let setValue = "new-value"
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        callsUpdateListenerExpectation.expectedFulfillmentCount = 1
        let subscription = wrapper.$properties.addUpdateListener { result in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        wrapper.properties = [secondValue, firstValue, thirdValue]

        firstValue.property = "different-value"
        secondValue.property = setValue

        XCTAssertEqual(secondValue.property, setValue)
        waitForExpectations(timeout: 1)
    }
}
#endif
