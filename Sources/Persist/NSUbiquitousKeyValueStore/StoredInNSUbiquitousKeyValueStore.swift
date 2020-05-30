#if os(macOS) || os(iOS) || os(tvOS)
import Foundation

/// A propety wrapper that stores a value in `NSUbiquitousKeyValueStore`.
public typealias StoredInNSUbiquitousKeyValueStore<Value: StorableInNSUbiquitousKeyValueStore> = Persisted<Value>
#endif
