#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
/**
 A transformer that transforms between a `StorableInUserDefaults` value and `UserDefaultsValue`.
 */
internal struct StorableInUserDefaultsTransformer<Input: StorableInUserDefaults>: Transformer {
    struct InternalStorableInUserDefaultsConformanceError: Error, CustomStringConvertible {
        let conformedValue: Input

        var description: String {
            return "\(Input.self) has been conformed to `StorableInUserDefaults` outside of `Persist`. This is not supported."
        }
    }

    /**
     Transform the provided `StorableInUserDefaults` value to a `UserDefaultsValue`.

     - parameter value: The `StorableInUserDefaults` value to transform.
     - returns: The `UserDefaultsValue` value.
     */
    internal func transformValue(_ value: Input) throws -> UserDefaultsValue {
        guard let value = value as? InternalStorableInUserDefaults else {
            throw InternalStorableInUserDefaultsConformanceError(conformedValue: value)
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
    internal func untransformValue(_ output: UserDefaultsValue) throws -> Input {
        guard let value = output.cast(to: Input.self) else {
            throw PersistenceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
#endif
