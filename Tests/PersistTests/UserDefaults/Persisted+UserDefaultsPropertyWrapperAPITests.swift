#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Persist
import TestHelpers

final class PersistedUserDefaultsPropertyWrapperAPITests: XCTestCase {

    private let userDefaults = UserDefaults.standard

    override func tearDown() {
        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
    }

    func testPropertyWrapperAPI() {
        struct PropertyWrappers {
            @Persisted(key: "stringValue_storedByAPI", storedBy: UserDefaults.standard, defaultValuePersistBehaviour: [])
            var stringValue_storedByAPI = "default"

            @Persisted(key: "stringValue_userDefaultsAPI", userDefaults: .standard, defaultValuePersistBehaviour: [])
            var stringValue_userDefaultsAPI = "default"

            @Persisted(key: "optionalStringValue_storedByAPI", storedBy: UserDefaults.standard, defaultValuePersistBehaviour: [])
            var optionalStringValue_storedByAPI: String?

            @Persisted(key: "optionalStringValue_userDefaultsAPI", userDefaults: .standard, defaultValuePersistBehaviour: [])
            var optionalStringValue_userDefaultsAPI: String?

            @Persisted(key: "optionalStringValueExplicitDefault_storedByAPI", storedBy: UserDefaults.standard, defaultValuePersistBehaviour: [])
            var optionalStringValueExplicitDefault_storedByAPI: String? = nil

            @Persisted(key: "optionalStringValueExplicitDefault_userDefaultsAPI", userDefaults: .standard, defaultValuePersistBehaviour: [])
            var optionalStringValueExplicitDefault_userDefaultsAPI: String? = nil

            @Persisted(key: "stringDataWithTransformer_storedByAPI", storedBy: UserDefaults.standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var stringDataWithTransformer_storedByAPI = "default"

            @Persisted(key: "stringDataWithTransformer_userDefaultsAPI", userDefaults: .standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var stringDataWithTransformer_userDefaultsAPI = "default"

            @Persisted(key: "optionalStringValueWithTransformer_storedByAPI", storedBy: UserDefaults.standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformer_storedByAPI: String?

            @Persisted(key: "optionalStringValueWithTransformer_userDefaultsAPI", userDefaults: .standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformer_userDefaultsAPI: String?

            @Persisted(key: "optionalStringValueWithTransformerExplicitDefault_storedByAPI", storedBy: UserDefaults.standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformerExplicitDefault_storedByAPI: String? = nil

            @Persisted(key: "optionalStringValueWithTransformerExplicitDefault_userDefaultsAPI", userDefaults: .standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
            var optionalStringValueWithTransformerExplicitDefault_userDefaultsAPI: String? = nil
        }

        let propertyWrappers = PropertyWrappers()

        XCTAssertEqual(propertyWrappers.stringValue_storedByAPI, "default")
        XCTAssertEqual(propertyWrappers.stringValue_userDefaultsAPI, "default")
        XCTAssertNil(propertyWrappers.optionalStringValue_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValue_userDefaultsAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueExplicitDefault_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueExplicitDefault_userDefaultsAPI)

        XCTAssertEqual(propertyWrappers.stringDataWithTransformer_storedByAPI, "default")
        XCTAssertEqual(propertyWrappers.stringDataWithTransformer_userDefaultsAPI, "default")
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformer_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformer_userDefaultsAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformerExplicitDefault_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformerExplicitDefault_userDefaultsAPI)
    }
}
#endif
