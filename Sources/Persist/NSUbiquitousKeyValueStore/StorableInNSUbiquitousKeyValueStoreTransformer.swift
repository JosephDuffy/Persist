#if os(macOS) || os(iOS) || os(tvOS)
/**
 A transformer that transforms between a `StorableInNSUbiquitousKeyValueStore` value and `NSUbiquitousKeyValueStoreValue`.
 */
internal struct StorableInNSUbiquitousKeyValueStoreTransformer<Input: StorableInNSUbiquitousKeyValueStore>: Transformer {

    /**
     Transform the provided `StorableInNSUbiquitousKeyValueStore` value to a `NSUbiquitousKeyValueStoreValue`.

     - parameter value: The `StorableInNSUbiquitousKeyValueStore` value to transform.
     - returns: The `NSUbiquitousKeyValueStoreValue` value.
     */
    internal func transformValue(_ value: Input) -> NSUbiquitousKeyValueStoreValue {
        guard let value = value as? InternalStorableInNSUbiquitousKeyValueStore else {
            preconditionFailure("\(Input.self) has been conformed to `StorableInNSUbiquitousKeyValueStore` outside of `Persist`. This is not supported.")
        }
        return value.asNSUbiquitousKeyValueStoreValue
    }

    /**
     Untransform the provided `NSUbiquitousKeyValueStoreValue` value to a `StorableInNSUbiquitousKeyValueStore`.

     - parameter output: The `NSUbiquitousKeyValueStoreValue` value to transform.
     - throws: `PersistenceError.unexpectedValueType` when the `output` cannot be
        converted to `StorableInNSUbiquitousKeyValueStore`.
     - returns: The `StorableInNSUbiquitousKeyValueStore` value.
    */
    internal func untransformValue(_ output: NSUbiquitousKeyValueStoreValue) throws -> Input {
        guard let value = output.cast(to: Input.self) else {
            throw PersistenceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
#endif
