import PersistCore

public final class MockTransformer<Value>: Transformer {
    public typealias Input = Value

    public typealias Output = Value

    public var transformValueParameter: Value?

    public var transformedValue: Value?

    public var untransformValueParameter: Value?

    public var untransformedValue: Value?

    public var errorToThrow: Error?

    public init() {}

    public func transformValue(_ value: Value) throws -> Value {
        transformValueParameter = value

        try errorToThrow.map { throw $0 }

        return transformedValue ?? value
    }

    public func untransformValue(_ output: Value) throws -> Value {
        untransformValueParameter = output

        try errorToThrow.map { throw $0 }

        return untransformedValue ?? output
    }
}
