#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

extension Persister where Value: StorableInUserDefaults {

    public convenience init(
        key: String,
        storedBy userDefaults: UserDefaults
    ) {
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: StorableInUserDefaultsTransformer<Value>()
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
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer
        )
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
            transformer: aggregateTransformer
        )
    }

}
#endif
