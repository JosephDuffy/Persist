#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
/// A type that's stored in a dictionary within `UserDefaults`.
public protocol StoredInUserDefaultsDictionary {
    /// An identifier that can uniquely identifier an instance to enable reordering
    var id: String { get }
    var storage: UserDefaultsArrayDictionaryStorage { get }
}
#endif
