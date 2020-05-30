#if os(macOS) || os(iOS) || os(tvOS)
public struct StorableInNSUbiquitousKeyValueStoreTransformer<Input: StorableInUbiquitousKeyValueStore>: Transformer {

    public func transformValue(_ value: Input) -> NSUbiquitousKeyValueStoreValue {
        return value.asUbiquitousKeyValueStoreValue
    }

    public func untransformValue(_ output: NSUbiquitousKeyValueStoreValue) throws -> Input {
        guard let value = output.value as? Input else {
            throw PersistanceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
#endif
