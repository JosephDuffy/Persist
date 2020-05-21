import Foundation

public protocol StorableInUserDefaults {
    var asPropertyListValue: UserDefaultsValue { get }
}

public typealias StoredInUserDefaults<Value: StorableInUserDefaults> = Persisted<Value>

extension StoredInUserDefaults {

    public init(
        key: String,
        userDefaults: UserDefaults,
        defaultValue: Value? = nil
    ) {
        self.init(persister: Persister(key: key, userDefaults: userDefaults), defaultValue: defaultValue)
    }

}

extension Persisted {

    public init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer,
        defaultValue: Value? = nil
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let persister = Persister(key: key, userDefaults: userDefaults, transformer: transformer)
        self.init(persister: persister, defaultValue: defaultValue)
    }

}

extension Persister where Value: StorableInUserDefaults {

    public convenience init(
        key: String,
        userDefaults: UserDefaults
    ) {
        self.init(key: key, storedBy: userDefaults, transformer: StorableInUserDefaultsTransformer<Value>())
    }

}

extension Persister {

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output: StorableInUserDefaults {
        let aggregateTransformer = transformer.append(transformer: StorableInUserDefaultsTransformer<Transformer.Output>())
        self.init(key: key, storedBy: userDefaults, transformer: aggregateTransformer)
    }

    public convenience init<Transformer: Persist.Transformer>(
        key: String,
        userDefaults: UserDefaults,
        transformer: Transformer
    ) where Transformer.Input == Value, Transformer.Output == UserDefaultsValue {
        self.init(key: key, storedBy: userDefaults, transformer: transformer)
    }

}

extension String: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .string(self)
    }
}

extension Data: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .data(self)
    }
}

extension URL: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .url(self)
    }
}

extension Bool: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .bool(self)
    }
}

extension Int: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .int(self)
    }
}

extension Double: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .double(self)
    }
}

extension Float: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .float(self)
    }
}

extension Array: StorableInUserDefaults where Element: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .array(map(\.asPropertyListValue))
    }
}

extension Dictionary: StorableInUserDefaults where Key == String, Value: StorableInUserDefaults {
    public var asPropertyListValue: UserDefaultsValue {
        return .dictionary(mapValues(\.asPropertyListValue))
    }
}
