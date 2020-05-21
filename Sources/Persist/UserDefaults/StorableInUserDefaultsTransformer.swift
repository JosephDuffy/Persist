public struct StorableInUserDefaultsTransformer<Input: StorableInUserDefaults>: Transformer {

    public func transformValue(_ value: Input) -> UserDefaultsValue {
        return value.asPropertyListValue
    }

    public func untransformValue(from output: UserDefaultsValue) -> Input {
        guard let value = output.value as? Input else {
            throw PersistanceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
