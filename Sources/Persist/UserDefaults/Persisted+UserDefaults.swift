#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

extension StoredInUserDefaults {

    public init(
        key: String,
        defaultValue: Value? = nil,
        storedBy userDefaults: UserDefaults
    ) {
        self.init(key: key, defaultValue: defaultValue, userDefaults: userDefaults)
    }

    public init(
        key: String,
        defaultValue: Value? = nil,
        userDefaults: UserDefaults
    ) {
        let persister = Persister<Value>(key: key, userDefaults: userDefaults)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        storedBy userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        self.init(key: key, defaultValue: defaultValue, userDefaults: userDefaults, transformer: transformer)
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let persister = Persister(key: key, userDefaults: userDefaults, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}
#endif
