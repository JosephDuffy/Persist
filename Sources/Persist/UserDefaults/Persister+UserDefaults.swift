#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

extension Persister where Value: StorableInUserDefaults {

    public convenience init(
        key: String,
        storedBy userDefaults: UserDefaults
    ) {
        self.init(
            key: key,
            userDefaults: userDefaults
        )
    }

    public convenience init(
        key: String,
        userDefaults: UserDefaults
    ) {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<Value>()
        )
    }

}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(
            key: key,
            userDefaults: userDefaults,
            transformer: transformer
        )
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let storage = UserDefaultsStorage(userDefaults: userDefaults)
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: storage,
            transformer: aggregateTransformer
        )
    }

}
#endif
