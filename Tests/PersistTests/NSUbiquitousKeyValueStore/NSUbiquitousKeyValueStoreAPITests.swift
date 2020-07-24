#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Persist

final class NSUbiquitousKeyValueStoreAPITests: XCTestCase {

    func testPersistedAPI() {
        _ = Persisted<Double?>(key: "test", storedBy: NSUbiquitousKeyValueStore.default)
        _ = Persisted(key: "test", storedBy: NSUbiquitousKeyValueStore.default, defaultValue: 123)

        _ = Persisted<Double?>(key: "test", nsUbiquitousKeyValueStore: .default)
        _ = Persisted(key: "test", nsUbiquitousKeyValueStore: .default, defaultValue: 123)

        _ = Persisted<Double?>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer())
        _ = Persisted(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: JSONTransformer())
        _ = Persisted(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: JSONTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer())
        _ = Persisted(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer(), defaultValue: 123)

        _ = Persisted<Double?>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: JSONTransformer())
        _ = Persisted(key: "test", nsUbiquitousKeyValueStore: .default, transformer: JSONTransformer(), defaultValue: 123)
    }

    func testPersisterAPI() {
        _ = Persister<Double?>(key: "test", storedBy: NSUbiquitousKeyValueStore.default)
        _ = Persister(key: "test", storedBy: NSUbiquitousKeyValueStore.default, defaultValue: 123)

        _ = Persister<Double?>(key: "test", nsUbiquitousKeyValueStore: .default)
        _ = Persister(key: "test", nsUbiquitousKeyValueStore: .default, defaultValue: 123)

        _ = Persister<Double?>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer())
        _ = Persister(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: MockTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: JSONTransformer())
        _ = Persister(key: "test", storedBy: NSUbiquitousKeyValueStore.default, transformer: JSONTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer())
        _ = Persister(key: "test", nsUbiquitousKeyValueStore: .default, transformer: MockTransformer(), defaultValue: 123)

        _ = Persister<Double?>(key: "test", nsUbiquitousKeyValueStore: .default, transformer: JSONTransformer())
        _ = Persister(key: "test", nsUbiquitousKeyValueStore: .default, transformer: JSONTransformer(), defaultValue: 123)
    }

}
#endif
