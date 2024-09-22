import Persist
import Foundation

struct TestStruct {
//    @Persist(key: "test-key", userDefaults: \Self.userDefaults)
//    static var testStaticProperty: Int = 0
//
//    private static let userDefaults = UserDefaults.standard

    @Persist(key: "test-key", userDefaults: \Self.userDefaults)
    var testProperty: Int = 0

    @Persist(key: "second-test-key", userDefaults: .standard)
    var testProperty2: Int = 12

    @Persist(key: "optional-test-key", userDefaults: .standard)
    var optionalTestProperty: Int?

    @Persist(key: "private-set-key", userDefaults: .standard)
    private(set) var privateSetProperty: Int?

    @Persist(key: "optional-test-key", userDefaults: .standard)
    var optionalURLTestProperty: URL?

    @Persist(key: "optional-test-key", userDefaults: .standard)
    var optionalUnsupportedTestProperty: String?

//    @Persist(
//        key: "transformed-key",
//        storage: UserDefaultsStorage(.standard),
//        transformer: JSONTransformer<TaskPriority>()
//    )
//    var transformedProperty: TaskPriority?

    @Persist(key: "optional-test-key", storage: \Self.dictionaryStorage)
    var optionalDictionaryTestProperty: Int?

    private let userDefaultsStorage = UserDefaultsStorage(.standard)

    private let userDefaults = UserDefaults.standard

    private var dictionaryStorage = DictionaryStorage()

    func setPrivateSetProperty(_ newValue: Int?) {
        privateSetProperty = newValue
    }
}

func foo() {
    var test = TestStruct()
    test.$testProperty.addUpdateListener {
        print($0)
    }
    test.testProperty = 123
    test.optionalDictionaryTestProperty = 1234
//    test.privateSetProperty = 111
    test.setPrivateSetProperty(222)
}
