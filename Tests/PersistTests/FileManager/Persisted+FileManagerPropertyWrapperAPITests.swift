#if !os(watchOS)
import XCTest
import Persist

final class PersistedFileManagerPropertyWrapperAPITests: XCTestCase {

    func testPropertyWrapperAPI() {
        struct PropertyWrappers {
            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), storedBy: FileManager.default, defaultValuePersistBehaviour: [])
            var dataValue_storedByAPI = Data("default".utf8)

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), fileManager: .default, defaultValuePersistBehaviour: [])
            var dataValue_fileManagerAPI = Data("default".utf8)

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), storedBy: FileManager.default, defaultValuePersistBehaviour: [])
            var optionalDataValue_storedByAPI: Data?

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), fileManager: .default, defaultValuePersistBehaviour: [])
            var optionalDataValue_fileManagerAPI: Data?

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), storedBy: FileManager.default, defaultValuePersistBehaviour: [])
            var optionalDataValueExplicitDefault_storedByAPI: Data? = nil

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), fileManager: .default, defaultValuePersistBehaviour: [])
            var optionalDataValueExplicitDefault_fileManagerAPI: Data? = nil

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), storedBy: FileManager.default, transformer: MockTransformer<Data>(), defaultValuePersistBehaviour: [])
            var stringDataWithTransformer_storedByAPI = Data("default".utf8)

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), fileManager: .default, transformer: MockTransformer<Data>(), defaultValuePersistBehaviour: [])
            var stringDataWithTransformer_fileManagerAPI = Data("default".utf8)

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), storedBy: FileManager.default, transformer: MockTransformer<Data>(), defaultValuePersistBehaviour: [])
            var optionalDataValueWithTransformer_storedByAPI: Data?

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), fileManager: .default, transformer: MockTransformer<Data>(), defaultValuePersistBehaviour: [])
            var optionalDataValueWithTransformer_fileManagerAPI: Data?

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), storedBy: FileManager.default, transformer: MockTransformer<Data>(), defaultValuePersistBehaviour: [])
            var optionalDataValueWithTransformerExplicitDefault_storedByAPI: Data? = nil

            @Persisted(key: URL(fileURLWithPath: "/dev/null", isDirectory: false), fileManager: .default, transformer: MockTransformer<Data>(), defaultValuePersistBehaviour: [])
            var optionalDataValueWithTransformerExplicitDefault_fileManagerAPI: Data? = nil
        }

        let propertyWrappers = PropertyWrappers()

        XCTAssertEqual(propertyWrappers.dataValue_storedByAPI, Data("default".utf8))
        XCTAssertEqual(propertyWrappers.dataValue_fileManagerAPI, Data("default".utf8))
        XCTAssertNil(propertyWrappers.optionalDataValue_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalDataValue_fileManagerAPI)
        XCTAssertNil(propertyWrappers.optionalDataValueExplicitDefault_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalDataValueExplicitDefault_fileManagerAPI)

        XCTAssertEqual(propertyWrappers.stringDataWithTransformer_storedByAPI, Data("default".utf8))
        XCTAssertEqual(propertyWrappers.stringDataWithTransformer_fileManagerAPI, Data("default".utf8))
        XCTAssertNil(propertyWrappers.optionalDataValueWithTransformer_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalDataValueWithTransformer_fileManagerAPI)
        XCTAssertNil(propertyWrappers.optionalDataValueWithTransformerExplicitDefault_storedByAPI)
        XCTAssertNil(propertyWrappers.optionalDataValueWithTransformerExplicitDefault_fileManagerAPI)
    }
}
#endif
