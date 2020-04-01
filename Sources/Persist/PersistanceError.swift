public enum PersistanceError: Error {
    case unexpectedValueType(value: Any, expected: Any.Type)
}
