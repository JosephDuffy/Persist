import Persist
import Foundation

struct TestStruct {
    @Persist(key: "test-key", storage: \Self.userDefaultsStorage)
    var testProperty: Int = 0

    @Persist(key: "second-test-key", storage: UserDefaultsStorage(.standard))
    var testProperty2: Int = 12

    @Persist(key: "optional-test-key", storage: UserDefaultsStorage(.standard))
    var optionalTestProperty: Int?

    @Persist(key: "private-set-key", storage: UserDefaultsStorage(.standard))
    private(set) var privateSetProperty: Int?

    @Persist(key: "optional-test-key", storage: UserDefaultsStorage(.standard))
    var optionalURLTestProperty: URL?

    @Persist(key: "optional-test-key", storage: UserDefaultsStorage(.standard))
    var optionalUnsupportedTestProperty: String?

    @Persist(
        key: "transformed-key",
        storage: UserDefaultsStorage(.standard),
        transformer: JSONTransformer<TaskPriority>()
    )
    var transformedProperty: TaskPriority?

    @Persist(key: "optional-test-key", storage: \Self.dictionaryStorage)
    var optionalDictionaryTestProperty: Int?

    private let userDefaultsStorage = UserDefaultsStorage(.standard)

    private var dictionaryStorage = DictionaryStorage()

    func setPrivateSetProperty(_ newValue: Int?) {
        privateSetProperty = newValue
    }
}

func foo() {
    var test = TestStruct()
    test.testProperty = 123
    test.optionalDictionaryTestProperty = 1234
//    test.privateSetProperty = 111
    test.setPrivateSetProperty(222)
}
