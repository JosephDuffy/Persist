#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Persist

final class UserDefaultsTestsAPITests: XCTestCase {

    func testPersistedAPI() {
        _ = Persisted<Double?>(key: "test", storedBy: UserDefaults.standard)
        _ = Persisted(key: "test", storedBy: UserDefaults.standard, defaultValue: 123)

        _ = Persisted<Double?>(key: "test", userDefaults: .standard)
        _ = Persisted(key: "test", userDefaults: .standard, defaultValue: 123)

        _ = Persisted<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer())
        _ = Persisted(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer())
        _ = Persisted(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", userDefaults: .standard, transformer: MockTransformer())
        _ = Persisted(key: "test", userDefaults: .standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", userDefaults: .standard, transformer: JSONTransformer())
        _ = Persisted(key: "test", userDefaults: .standard, transformer: JSONTransformer(), defaultValue: 123)
    }

    func testPersisterAPI() {
        _ = Persister<Double?>(key: "test", storedBy: UserDefaults.standard)
        _ = Persister(key: "test", storedBy: UserDefaults.standard, defaultValue: 123)

        _ = Persister<Double?>(key: "test", userDefaults: .standard)
        _ = Persister(key: "test", userDefaults: .standard, defaultValue: 123)

        _ = Persister<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer())
        _ = Persister(key: "test", storedBy: UserDefaults.standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer())
        _ = Persister(key: "test", storedBy: UserDefaults.standard, transformer: JSONTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", userDefaults: .standard, transformer: MockTransformer())
        _ = Persister(key: "test", userDefaults: .standard, transformer: MockTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", userDefaults: .standard, transformer: JSONTransformer())
        _ = Persister(key: "test", userDefaults: .standard, transformer: JSONTransformer(), defaultValue: 123)
    }

}
#endif
