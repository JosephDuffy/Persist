#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

public protocol StorableInUserDefaults {
    var asUserDefaultsValue: UserDefaultsValue { get }
}

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

extension Persister where Value: StorableInUserDefaults {

    public convenience init(
        key: String,
        storedBy storage: UserDefaults
    ) {
        self.init(
            key: key,
            storedBy: storage,
            transformer: StorableInUserDefaultsTransformer<Value>()
        )
    }

    public convenience init(
        key: String,
        userDefaults: UserDefaults
    ) {
        self.init(
            key: key,
            storedBy: userDefaults,
            transformer: StorableInUserDefaultsTransformer<Value>()
        )
    }

}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        storedBy storage: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(
            key: key,
            storedBy: storage,
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
            storedBy: userDefaults,
            transformer: aggregateTransformer
        )
    }

}

extension String: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .string(self)
    }
}

extension Data: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .data(self)
    }
}

extension URL: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .url(self)
    }
}

extension Bool: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .bool(self)
    }
}

extension Int: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .int(self)
    }
}

extension Double: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .double(self)
    }
}

extension Float: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .float(self)
    }
}

extension Array: StorableInUserDefaults where Element: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .array(map(\.asUserDefaultsValue))
    }
}

extension Dictionary: StorableInUserDefaults where Key == String, Value: StorableInUserDefaults {
    public var asUserDefaultsValue: UserDefaultsValue {
        return .dictionary(mapValues(\.asUserDefaultsValue))
    }
}
#endif
