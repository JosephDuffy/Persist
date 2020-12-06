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
        let storage = UserDefaultsMappedArrayStorage(userDefaults: userDefaults) { storage in
            try Model(storage: storage)
        }

        let dictionaryKey = "TestKey"

        let firstValue = try storage.createNewValue(forKey: dictionaryKey) { storage in
            try Model(storage: storage, id: "first-value")
        }

        let secondValue = try storage.createNewValue(forKey: dictionaryKey) { storage in
            try Model(storage: storage, id: "second-value")
        }

        let thirdValue = try storage.createNewValue(forKey: dictionaryKey) { storage in
            try Model(storage: storage, id: "third-value")
        }

        XCTAssertEqual(try storage.retrieveValue(for: dictionaryKey), [firstValue, secondValue, thirdValue])

        let setValue = "second-value-property"
        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = secondValue.$property.addUpdateListener { result in
            defer {
                callsUpdateListenerExpectation.fulfill()
            }

            XCTAssertEqual((try? result.get())?.newValue, setValue, "Value passed to update listener should be new value")
        }
        _ = subscription

        try storage.storeValue([secondValue, firstValue], key: dictionaryKey)

        firstValue.property = "first-value-property"
        secondValue.property = setValue

        XCTAssertEqual(try storage.retrieveValue(for: dictionaryKey), [secondValue, firstValue])
        XCTAssertEqual(secondValue.property, setValue)
        waitForExpectations(timeout: 1)
    }

    func testArrayPropertyUpdates() throws {
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

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        /// Once for the creation of each value (3), once for setting the properties array (1), once
        /// for each property being set (2)
        callsUpdateListenerExpectation.expectedFulfillmentCount = 6
        let subscription = wrapper.$properties.addUpdateListener { result in
            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        let firstValue = try wrapper.addProperty()
        let secondValue = try wrapper.addProperty()
        let thirdValue = try wrapper.addProperty()

        wrapper.properties = [secondValue, firstValue, thirdValue]

        firstValue.property = "different-value"
        secondValue.property = "new-value"

        waitForExpectations(timeout: 1)
    }

    func testArrayPropertyInitialCreation() throws {
        struct Wrapper {
            @Persisted
            var properties: [Model]

            private let storage: UserDefaultsMappedArrayStorage<Model>

            init(storage: UserDefaultsMappedArrayStorage<Model>) {
                _properties = Persisted(key: "TestKey", storedBy: storage, defaultValue: [])
                self.storage = storage
            }

            public func addProperty(withId id: String) throws -> Model {
                return try storage.createNewValue(forKey: "TestKey") { storage in
                    try Model(storage: storage, id: id)
                }
            }
        }

        let storage = UserDefaultsMappedArrayStorage(userDefaults: userDefaults) { storage in
            try Model(storage: storage)
        }

        let wrapper = Wrapper(storage: storage)
        let createdModelId = "created-id"

        let callsUpdateListenerExpectation = expectation(description: "Calls update listener")
        let subscription = wrapper.$properties.addUpdateListener { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue.first?.id, createdModelId)
            case .failure:
                XCTFail("Should not fail")
            }

            callsUpdateListenerExpectation.fulfill()
        }
        _ = subscription

        _ = try wrapper.addProperty(withId: createdModelId)

        waitForExpectations(timeout: 0.1)
    }

    /// This usage is not recommended (`UserDefaultsMappedArrayStorage` should on really
    /// be used to handle a single key) but the API allows it so it should work.
    func testStoringValuesWithSameIdAcrossMultipleKeys() throws {
        let storage = UserDefaultsMappedArrayStorage(userDefaults: userDefaults) { storage in
            try Model(storage: storage)
        }

        let keyA = "KeyA"
        let keyB = "KeyB"
        let identifier = "identifier"

        _ = try storage.createNewValue(forKey: keyA) { storage in
            try Model(storage: storage, id: identifier)
        }

        let firstKeyBValue = try storage.createNewValue(forKey: keyB) { storage in
            try Model(storage: storage, id: identifier)
        }

        let retrievedFirstKeyAValue = try storage.retrieveValue(for: keyA)?.first!

        let doesNotCallKeyAUpdateListenerExpectation = expectation(description: "Calls update listener")
        doesNotCallKeyAUpdateListenerExpectation.isInverted = true
        let keyASubscription = retrievedFirstKeyAValue!.$property.addUpdateListener { result in
            doesNotCallKeyAUpdateListenerExpectation.fulfill()
        }
        _ = keyASubscription

        let doesCallKeyBUpdateListenerExpectation = expectation(description: "Calls update listener")
        let keyBSubscription = firstKeyBValue.$property.addUpdateListener { result in
            doesCallKeyBUpdateListenerExpectation.fulfill()
            switch result {
            case .success(let update):
                XCTAssertEqual(update.newValue, "new value")
            case .failure:
                XCTFail("Should not fail")
            }
        }
        _ = keyBSubscription

        firstKeyBValue.property = "new value"

        waitForExpectations(timeout: 0.1)
    }

    func testAccessFromMultipleQueues() throws {
        let storage = UserDefaultsMappedArrayStorage(userDefaults: userDefaults) { storage in
            try Model(storage: storage)
        }

        let arrayKey = "ArrayKey"
        let iterations = 100

        let createsModelExpectation = expectation(description: "Creates model")
        createsModelExpectation.expectedFulfillmentCount = iterations
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            do {
                _ = try storage.createNewValue(forKey: arrayKey) { storage in
                    try Model(storage: storage, id: String(describing: index))
                }
                createsModelExpectation.fulfill()
            } catch {
                XCTFail(String(describing: error))
            }
        }

        waitForExpectations(timeout: 1)

        let createdValues = try storage.retrieveValue(for: arrayKey)
        let createdValueIds = Set(createdValues?.map(\.id) ?? [])
        let expectedValueIds = Set((0..<iterations).map(String.init(describing:)))
        XCTAssertEqual(createdValues?.count, iterations, "Should store a model for every iteration")
        XCTAssertEqual(createdValueIds, expectedValueIds, "Should store models with the provided ids")
    }
}

private struct Model: StoredInUserDefaultsDictionary, Equatable, CustomStringConvertible {
    static let idUserDefaultsKey = "id"

    static func == (lhs: Model, rhs: Model) -> Bool {
        lhs.id == rhs.id && lhs.property == rhs.property
    }

    let id: String

    @Persisted
    var property: String?

    let storage: UserDefaultsArrayDictionaryStorage

    var description: String {
        "<Model id=\(id); property=\(property ?? "nil")>"
    }

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

#endif
