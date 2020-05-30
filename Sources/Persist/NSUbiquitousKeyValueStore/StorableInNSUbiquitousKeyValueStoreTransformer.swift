#if os(macOS) || os(iOS) || os(tvOS)
public struct StorableInNSUbiquitousKeyValueStoreTransformer<Input: StorableInNSUbiquitousKeyValueStore>: Transformer {

    public func transformValue(_ value: Input) -> NSUbiquitousKeyValueStoreValue {
        return value.asNSUbiquitousKeyValueStoreValue
    }

    public func untransformValue(_ output: NSUbiquitousKeyValueStoreValue) throws -> Input {
        guard let value = output.value as? Input else {
            throw PersistenceError.unexpectedValueType(value: output.value, expected: Input.self)
        }

        return value
    }

}
#endif
