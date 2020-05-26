#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
public struct StorableInUserDefaultsTransformer<Input: StorableInUserDefaults>: Transformer {

    public func transformValue(_ value: Input) -> UserDefaultsValue {
        return value.asUserDefaultsValue
    }

    public func untransformValue(from output: UserDefaultsValue) throws -> Input {
        guard let value = output.value as? Input else {
            throw PersistanceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
#endif
