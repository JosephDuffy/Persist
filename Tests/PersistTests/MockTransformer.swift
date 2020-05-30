import Persist

internal final class MockTransformer<Value>: Transformer {

    internal typealias Input = Value

    internal typealias Output = Value

    internal var errorToThrow: Error?

    func transformValue(_ value: Value) throws -> Value {
        try errorToThrow.map { throw $0 }

        return value
    }

    func untransformValue(_ output: Value) throws -> Value {
        try errorToThrow.map { throw $0 }

        return output
    }

}
