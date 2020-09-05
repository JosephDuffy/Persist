#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Persist
import TestHelpers

final class PersistedNSUbiquitousKeyValueStorePropertyWrapperAPITests: XCTestCase {

    private let nsUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default

    override func tearDown() {
        nsUbiquitousKeyValueStore.dictionaryRepresentation.keys.forEach(nsUbiquitousKeyValueStore.removeObject(forKey:))
    }

    func testPropertyWrapperAPI() {
        struct PropertyWrappers {
            @Persisted(key: "stringValue_storedByAPI", storedBy: NSUbiquitousKeyValueStore.default, defaultValuePersistBehaviour: [])
            var stringValue_storedByAPI = "default"

            @Persisted(key: "stringValue_nsUbiquitousKeyValueStoreAPI", nsUbiquitousKeyValueStore: .default, defaultValuePersistBehaviour: [])
            var stringValue_nsUbiquitousKeyValueStoreAPI = "default"

            @Persisted(key: "optionalStringValue_storedByAPI", storedBy: NSUbiquitousKeyValueStore.default, defaultValuePersistBehaviour: [])
            var optionalStringValue_storedByAPI: String?

            @Persisted(key: "optionalStringValue_nsUbiquitousKeyValueStoreAPI", nsUbiquitousKeyValueStore: .default, defaultValuePersistBehaviour: [])
            var optionalStringValue_nsUbiquitousKeyValueStoreAPI: String?

            @Persisted(key: "optionalStringValueExplicitDefault_storedByAPI", storedBy: NSUbiquitousKeyValueStore.default, defaultValuePersistBehaviour: [])
            var optionalStringValueExplicitDefault_storedByAPI: String? = nil

            @Persisted(key: "optionalStringValueExplicitDefault_nsUbiquitousKeyValueStoreAPI", nsUbiquitousKeyValueStore: .default, defaultValuePersistBehaviour: [])
            var optionalStringValueExplicitDefault_nsUbiquitousKeyValueStoreAPI: String? = nil

            @Persisted(key: "stringDataWithTransformer_storedByAPI", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var stringDataWithTransformer_storedByAPI = "default"

            @Persisted(key: "stringDataWithTransformer_nsUbiquitousKeyValueStoreAPI", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var stringDataWithTransformer_nsUbiquitousKeyValueStoreAPI = "default"

            @Persisted(key: "optionalStringValueWithTransformer_storedByAPI", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformer_storedByAPI: String?

            @Persisted(key: "optionalStringValueWithTransformer_nsUbiquitousKeyValueStoreAPI", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformer_nsUbiquitousKeyValueStoreAPI: String?

            @Persisted(key: "optionalStringValueWithTransformerExplicitDefault_storedByAPI", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformerExplicitDefault_storedByAPI: String? = nil

            @Persisted(key: "optionalStringValueWithTransformerExplicitDefault_nsUbiquitousKeyValueStoreAPI", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformerExplicitDefault_nsUbiquitousKeyValueStoreAPI: String? = nil
        }

        let propertyWrappers = PropertyWrappers()

        XCTAssertEqual(propertyWrappers.stringValue_storedByAPI, "default")
        XCTAssertEqual(propertyWrappers.stringValue_nsUbiquitousKeyValueStoreAPI, "default")
        XCTAssertNil(propertyWrappers.optionalStringValue_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValue_nsUbiquitousKeyValueStoreAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueExplicitDefault_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueExplicitDefault_nsUbiquitousKeyValueStoreAPI)

        XCTAssertEqual(propertyWrappers.stringDataWithTransformer_storedByAPI, "default")
        XCTAssertEqual(propertyWrappers.stringDataWithTransformer_nsUbiquitousKeyValueStoreAPI, "default")
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformer_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformer_nsUbiquitousKeyValueStoreAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformerExplicitDefault_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformerExplicitDefault_nsUbiquitousKeyValueStoreAPI)
    }
}
#endif
