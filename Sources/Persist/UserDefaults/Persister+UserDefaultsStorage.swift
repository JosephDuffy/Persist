#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

extension Persister where Value: StorableInUserDefaults {

    public convenience init(
        key: String,
        storedBy userDefaultsStorage: UserDefaultsStorage
    ) {
        self.init(
            key: key,
            userDefaultsStorage: userDefaultsStorage
        )
    }

    public convenience init(
        key: String,
        userDefaultsStorage: UserDefaultsStorage
    ) {
        self.init(
            key: key,
            storedBy: userDefaultsStorage,
            transformer: StorableInUserDefaultsTransformer<Value>()
        )
    }

}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(
            key: key,
            userDefaultsStorage: userDefaultsStorage,
            transformer: transformer
        )
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: userDefaultsStorage,
            transformer: aggregateTransformer
        )
    }

}
#endif
