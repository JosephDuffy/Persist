import Persist
import Foundation

private enum SharedThings {
    static var sharedUserDefaults: UserDefaults { .standard }
}

struct TestStruct: Sendable {
    @Persist(key: "test-key", userDefaults: UserDefaults.standard)
    static var testStaticProperty: Int = 0

    @Persist(key: "test-key", userDefaults: \Self.userDefaults)
    var testProperty: Int = 0

    @Persist(key: "second-test-key", userDefaults: .standard)
    var testProperty2: Int = 12

    @Persist(key: "optional-test-key", userDefaults: UserDefaults.standard)
    var optionalTestProperty: Int?

    @Persist(key: "optional-url", userDefaults: UserDefaults.standard)
    var optionalURL: URL?

    @Persist(key: "private-set-key", userDefaults: SharedThings.sharedUserDefaults)
    private(set) var privateSetProperty: Int?

    @Persist(key: "optional-test-key", userDefaults: .standard)
    var optionalURLTestProperty: URL?

    @Persist(key: "optional-test-key", userDefaults: .standard)
    var optionalUnsupportedTestProperty: String?

    @Persist(key: "stored-array-with-default", userDefaults: .standard)
    var storedArrayWithDefault: [String] = []

    @Persist(key: "stored-array-optional", userDefaults: .standard)
    var storedArrayOptional: [String]?

//    @Persist(
//        key: "transformed-key",
//        storage: UserDefaultsStorage(.standard),
//        transformer: JSONTransformer<TaskPriority>()
//    )
//    var transformedProperty: TaskPriority?

    @Persist(key: "optional-test-key", storage: \Self.dictionaryStorage)
    var optionalDictionaryTestProperty: Int?

    private let userDefaultsStorage = UserDefaultsStorage(.standard)

    private var userDefaults: UserDefaults { .standard }

    private var dictionaryStorage = DictionaryStorage()

    mutating func setPrivateSetProperty(_ newValue: Int?) {
        privateSetProperty = newValue
    }
}

func foo() {
    var test = TestStruct()
//    test.$testProperty.addUpdateListener {
//        print($0)
//    }
    test.testProperty = 123
    test.optionalDictionaryTestProperty = 1234
//    test.privateSetProperty = 111
    test.setPrivateSetProperty(222)
}
