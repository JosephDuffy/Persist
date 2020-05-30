import Foundation

/// A propety wrapper that stores a value in `UserDefaults`.
public typealias StoredInUserDefaults<Value: StorableInUserDefaults> = Persisted<Value>
