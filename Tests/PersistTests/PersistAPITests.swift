import Persist
import Foundation

struct TestStruct {
    @Persist(key: "test-key", storage: \Self.userDefaultsStorage)
    var testProperty: Int = 0

    @Persist(key: "second-test-key", storage: UserDefaultsStorage(.standard))
    var testProperty2: Int = 12

    @Persist(key: "optional-test-key", storage: UserDefaultsStorage(.standard))
    var optionalTestProperty: Int?

    @Persist(key: "optional-test-key", storage: UserDefaultsStorage(.standard))
    var optionalURLTestProperty: URL?

    @Persist(key: "optional-test-key", storage: UserDefaultsStorage(.standard))
    var optionalUnsupportedTestProperty: String?

    @Persist(key: "optional-test-key", storage: \Self.dictionaryStorage)
    var optionalDictionaryTestProperty: Int?

    private let userDefaultsStorage = UserDefaultsStorage(.standard)

    private var dictionaryStorage = DictionaryStorage()
}

func foo() {
    var test = TestStruct()
    test.testProperty = 123
    test.optionalDictionaryTestProperty = 1234
}
