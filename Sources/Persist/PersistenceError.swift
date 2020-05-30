public enum PersistenceError: Error {
    case unexpectedValueType(value: Any, expected: Any.Type)
}
