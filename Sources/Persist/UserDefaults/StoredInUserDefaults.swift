#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Foundation

/// A propety wrapper that stores a value in `UserDefaults`.
public typealias StoredInUserDefaults<Value: StorableInUserDefaults> = Persisted<Value>
#endif
