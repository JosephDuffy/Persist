#if !os(watchOS)
import XCTest
import Persist

final class PersistedPropertyWrapperAPITests: XCTestCase {

    func testPropertyWrapperAPI() {
        struct PropertyWrappers {
            @Persisted(key: "stringValue", storedBy: InMemoryStorage<String>(), defaultValuePersistBehaviour: [])
            var stringValue: String = "default"

            @Persisted(key: "stringValueAnyStorage", storedBy: InMemoryStorage<Any>(), defaultValuePersistBehaviour: [])
            var stringValueAnyStorage: String = "default"

            @Persisted(key: "optionalStringValue", storedBy: InMemoryStorage<String>(), defaultValuePersistBehaviour: [])
            var optionalStringValue: String?

            @Persisted(key: "optionalStringValueExplicitDefault", storedBy: InMemoryStorage<String>(), defaultValuePersistBehaviour: [])
            var optionalStringValueExplicitDefault: String? = nil

            @Persisted(key: "optionalStringValueAnyStorage", storedBy: InMemoryStorage<Any>(), defaultValuePersistBehaviour: [])
            var optionalStringValueAnyStorage: String?

            @Persisted(key: "optionalStringValueAnyStorageExplicitDefault", storedBy: InMemoryStorage<Any>(), defaultValuePersistBehaviour: [])
            var optionalStringValueAnyStorageExplicitDefault: String? = nil

            @Persisted(key: "stringValueWithTransformer", storedBy: InMemoryStorage<String>(), transformer: MockTransformer<String>(), defaultValuePersistBehaviour: [])
            var stringValueWithTransformer: String = "default"

            @Persisted(key: "stringValueAnyStorageWithTransformer", storedBy: InMemoryStorage<Any>(), transformer: MockTransformer<String>(), defaultValuePersistBehaviour: [])
            var stringValueAnyStorageWithTransformer: String = "default"

            @Persisted(key: "optionalStringValueWithTransformer", storedBy: InMemoryStorage<String>(), transformer: MockTransformer<String>(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformer: String?

            @Persisted(key: "optionalStringValueAnyStorageWithTransformer", storedBy: InMemoryStorage<Any>(), transformer: MockTransformer<String>(), defaultValuePersistBehaviour: [])
            var optionalStringValueAnyStorageWithTransformer: String?

            @Persisted(key: "optionalStringValueWithTransformerExplicitDefault", storedBy: InMemoryStorage<String>(), transformer: MockTransformer<String>(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformerExplicitDefault: String? = nil

            @Persisted(key: "optionalStringValueAnyStorageWithTransformerExplicitDefault", storedBy: InMemoryStorage<Any>(), transformer: MockTransformer<String>(), defaultValuePersistBehaviour: [])
            var optionalStringValueAnyStorageWithTransformerExplicitDefault: String? = nil
        }

        let propertyWrappers = PropertyWrappers()

        XCTAssertEqual(propertyWrappers.stringValue, "default")
        XCTAssertEqual(propertyWrappers.stringValueAnyStorage, "default")
        XCTAssertNil(propertyWrappers.optionalStringValue)
        XCTAssertNil(propertyWrappers.optionalStringValueAnyStorage)
        XCTAssertNil(propertyWrappers.optionalStringValueExplicitDefault)
        XCTAssertNil(propertyWrappers.optionalStringValueAnyStorageExplicitDefault)

        XCTAssertEqual(propertyWrappers.stringValueWithTransformer, "default")
        XCTAssertEqual(propertyWrappers.stringValueAnyStorageWithTransformer, "default")
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformer)
        XCTAssertNil(propertyWrappers.optionalStringValueAnyStorageWithTransformer)
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformerExplicitDefault)
        XCTAssertNil(propertyWrappers.optionalStringValueAnyStorageWithTransformerExplicitDefault)
    }
}
#endif
