import Persist

internal final class MockTransformer<Value>: Transformer {

    internal typealias Input = Value

    internal typealias Output = Value

    internal var transformValueParameter: Value?

    internal var transformedValue: Value?

    internal var untransformValueParameter: Value?

    internal var untransformedValue: Value?

    internal var errorToThrow: Error?

    func transformValue(_ value: Value) throws -> Value {
        transformValueParameter = value

        try errorToThrow.map { throw $0 }

        return transformedValue ?? value
    }

    func untransformValue(_ output: Value) throws -> Value {
        untransformValueParameter = output

        try errorToThrow.map { throw $0 }

        return untransformedValue ?? output
    }

}
