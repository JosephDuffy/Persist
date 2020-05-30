#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

public typealias StoredInUserDefaults<Value: StorableInUserDefaults> = Persisted<Value>

extension StoredInUserDefaults {

    public init(
        key: String,
        defaultValue: Value? = nil,
        storedBy storage: UserDefaults
    ) {
        let persister = Persister<Value>(key: key, storedBy: storage)
        self.init(persister: persister, defaultValue: defaultValue)
    }

    public init(
        key: String,
        defaultValue: Value? = nil,
        userDefaults: UserDefaults
    ) {
        self.init(persister: Persister(key: key, userDefaults: userDefaults), defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        storedBy storage: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let persister = Persister(key: key, storedBy: storage, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

    public init<Transformer: Persist.Transformer>(
        key: String,
        defaultValue: Value? = nil,
        userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let persister = Persister(key: key, storedBy: userDefaults, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}
#endif
