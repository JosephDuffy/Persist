/// An option to persist the default value when returned by `Persisted`'s `wrappedValue`.
public struct DefaultValuePersistOption: OptionSet {

    /// Persist the default value when the `Persister` returns `nil`.
    public static let persistWhenNil = DefaultValuePersistOption(rawValue: 1 << 0)

    /// Persist the default value when the `Persister` throws and error.
    public static let persistOnError = DefaultValuePersistOption(rawValue: 1 << 1)

    /// Persist the default value when the `Persister` returns `nil` or throws and error.
    public static let all: DefaultValuePersistOption = [.persistWhenNil, .persistOnError]

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

}
