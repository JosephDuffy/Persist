import Foundation

/// A propety wrapper that stores a value in `NSUbiquitousKeyValueStore`.
public typealias StoredInNSUbiquitousKeyValueStore<Value: StorableInUbiquitousKeyValueStore> = Persisted<Value>
