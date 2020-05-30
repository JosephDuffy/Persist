#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

extension StoredInUserDefaults {

    public init(
        key: String,
        defaultValue: Value? = nil,
        storedBy userDefaultsStorage: UserDefaultsStorage
    ) {
        self.init(key: key, defaultValue: defaultValue, userDefaultsStorage: userDefaultsStorage)
    }

    public init(
        key: String,
        defaultValue: Value? = nil,
        userDefaultsStorage: UserDefaultsStorage
    ) {
        let persister = Persister<Value>(key: key, userDefaultsStorage: userDefaultsStorage)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        storedBy userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(key: key, defaultValue: defaultValue, userDefaultsStorage: userDefaultsStorage, transformer: transformer)
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        userDefaultsStorage: UserDefaultsStorage,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let persister = Persister(key: key, userDefaultsStorage: userDefaultsStorage, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}
#endif
