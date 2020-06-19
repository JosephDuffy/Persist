/// An option to persist the default value when returned by a `Persister`.
public struct DefaultValuePersistOption: OptionSet {

    /// Persist the default value when the stored value is `nil`.
    public static let persistWhenNil = DefaultValuePersistOption(rawValue: 1 << 0)

    /// Persist the default value when an error is thrown when trying to retrieve a value.
    public static let persistOnError = DefaultValuePersistOption(rawValue: 1 << 1)

    /// Persist the default value when the `Persister` returns `nil` or throws and error.
    public static let all: DefaultValuePersistOption = [.persistWhenNil, .persistOnError]

    /// The raw value of the option set.
    public let rawValue: Int

    /**
     Create a new `DefaultValuePersistOption` with the specified raw value.

     - parameter rawValue: The raw value
     */
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

}
