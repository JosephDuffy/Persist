#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
/**
 A transformer that transforms between a `StorableInUserDefaults` value and `UserDefaultsValue`.
 */
public struct StorableInUserDefaultsTransformer<Input: StorableInUserDefaults>: Transformer {

    /**
     Transform the provided `StorableInUserDefaults` value to a `UserDefaultsValue`.

     - parameter value: The `StorableInUserDefaults` value to transform.
     - returns: The `UserDefaultsValue` value.
     */
    public func transformValue(_ value: Input) -> UserDefaultsValue {
        guard let value = value as? InternalStorableInUserDefaults else {
            preconditionFailure("\(Input.self) has been conformed to `StorableInUserDefaults` outside of `Persist`. This is not supported.")
        }
        return value.asUserDefaultsValue
    }

    /**
     Untransform the provided `UserDefaultsValue` value to a `StorableInUserDefaults`.

     - parameter output: The `UserDefaultsValue` value to transform.
     - throws: `PersistenceError.unexpectedValueType` when the `output` cannot be
        converted to `StorableInUserDefaults`.
     - returns: The `StorableInUserDefaults` value.
    */
    public func untransformValue(_ output: UserDefaultsValue) throws -> Input {
        guard let value = output.cast(to: Input.self) else {
            throw PersistenceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
#endif
