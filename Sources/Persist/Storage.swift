/**
 A protocol that defines the interface to store, remove, and retrieve values by a string key.
 */
public protocol Storage {

    /**
     Store the provided value against the provided key.

     - parameter value: The value to store.
     - parameter key: The key to store the value against.
     */
    mutating func storeValue<Value>(_ value: Value, key: String) throws

    /**
     Remove the value for the provided key.

     - parameter key: The key of the value to remove.
     */
    mutating func removeValue(for key: String) throws

    /**
     Retrieve the value for the provided key.

     - throws: `PersistanceError.unexpectedValueType` if stored value that is not of type `Value`.
     - parameter key: The key of the value to retrieve.
     - returns: The stored value, or `nil` if no value is associated with the key.
     */
    func retrieveValue<Value>(for key: String) throws -> Value?
}

extension Storage {

    /**
     Retrieve the value for the provided key.

     This function is useful when the return type cannot be inferred from the context.

     - throws: `PersistanceError.unexpectedValueType` if stored value that is not of type `Value`.
     - parameter key: The key of the value to retrieve.
     - parameter type: The type of the value to retrieve.
     - returns: The stored value, or `nil` if no value is associated with the key.
     */
    public func retrieveValue<Value>(for key: String, ofType type: Value.Type) throws -> Value? {
        try retrieveValue(for: key)
    }

}
