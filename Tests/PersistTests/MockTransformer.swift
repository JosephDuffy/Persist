import Persist

internal final class MockTransformer<Value>: Transformer {

    internal typealias Input = Value

    internal typealias Output = Value

    func transformValue(_ value: Value) -> Value {
        return value
    }

    func untransformValue(_ output: Value) -> Value {
        return output
    }

}
