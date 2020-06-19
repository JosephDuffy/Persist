/**
 An error that occurs during persistence. This error may occur during storage or retrieval.
 */
public enum PersistenceError: Error {
    /**
     A value was provided, but it was not of the expected type.
     */
    case unexpectedValueType(value: Any, expected: Any.Type)
}
