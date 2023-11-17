//#if os(macOS) || os(iOS) || os(tvOS)
//import XCTest
//import Persist
//
//final class PersistedUserDefaultsPropertyWrapperAPITests: XCTestCase {
//
//    private let userDefaults = UserDefaults.standard
//
//    override func tearDown() {
//        userDefaults.dictionaryRepresentation().keys.forEach(userDefaults.removeObject(forKey:))
//    }
//
//    func testPropertyWrapperAPI() {
//        struct PropertyWrappers {
//            @Persisted(key: "stringValue", userDefaults: .standard, defaultValuePersistBehaviour: [])
//            var stringValue = "default"
//
//            @Persisted(key: "optionalStringValue", userDefaults: .standard, defaultValuePersistBehaviour: [])
//            var optionalStringValue: String?
//
//            @Persisted(key: "optionalStringValueExplicitDefault", userDefaults: .standard, defaultValuePersistBehaviour: [])
//            var optionalStringValueExplicitDefault: String? = nil
//
//            @Persisted(key: "stringDataWithTransformer", userDefaults: .standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
//            var stringDataWithTransformer = "default"
//
//            @Persisted(key: "optionalStringValueWithTransformer", userDefaults: .standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
//            var optionalStringValueWithTransformer: String?
//
//            @Persisted(key: "optionalStringValueWithTransformerExplicitDefault", userDefaults: .standard, transformer: MockTransformer(), defaultValuePersistBehaviour: [])
//            var optionalStringValueWithTransformerExplicitDefault: String? = nil
//        }
//
//        let propertyWrappers = PropertyWrappers()
//
//        XCTAssertEqual(propertyWrappers.stringValue, "default")
//        XCTAssertNil(propertyWrappers.optionalStringValue)
//        XCTAssertNil(propertyWrappers.optionalStringValueExplicitDefault)
//
//        XCTAssertEqual(propertyWrappers.stringDataWithTransformer, "default")
//        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformer)
//        XCTAssertNil(propertyWrappers.optionalStringValueWithTransformerExplicitDefault)
//    }
//}
//#endif
