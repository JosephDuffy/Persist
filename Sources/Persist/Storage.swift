/**
 A protocol that defines the interface to store, remove, and retrieve values by a string key.
 */
public protocol Storage: class {

    /// The type of the keys used to reference values in the storage.
    associatedtype Key

    /// The type of values that can be stored.
    associatedtype Value

    typealias UpdateListener = (Value?) -> Void

    /**
     Store the provided value against the provided key.

     - parameter value: The value to store.
     - parameter key: The key to store the value against.
     */
    func storeValue(_ value: Value, key: Key) throws

    /**
     Remove the value for the provided key.

     - parameter key: The key of the value to remove.
     */
    func removeValue(for key: Key) throws

    /**
     Retrieve the value for the provided key.

     - throws: `PersistenceError.unexpectedValueType` if stored value that is not of type `Value`.
     - parameter key: The key of the value to retrieve.
     - returns: The stored value, or `nil` if no value is associated with the key.
     */
    func retrieveValue(for key: Key) throws -> Value?

    /**
     Add a closure that will be called when a value is updated.

     - parameter key: The key to subscribe to changes to.
     - parameter updateListener: A closure to call when an update occurs.
     - returns: An object that can be used to cancel the subscription.
     */
    func addUpdateListener(forKey key: Key, updateListener: @escaping UpdateListener) -> Cancellable
}
