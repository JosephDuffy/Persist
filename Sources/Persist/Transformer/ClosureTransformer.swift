import Foundation

/**
 A transformer that transformers values to JSON data.
 */
public struct ClosureTransformer<Input, Output>: Transformer {
    public typealias InputClosure = (_ input: Input) throws -> Output

    public typealias OutputClosure = (_ output: Output) throws -> Input

    private let inputClosure: InputClosure

    private let outputClosure: OutputClosure

    public init(
        inputClosure: @escaping InputClosure,
        outputClosure: @escaping OutputClosure
    ) {
        self.inputClosure = inputClosure
        self.outputClosure = outputClosure
    }

    public func transformValue(_ value: Input) throws -> Output {
        try inputClosure(value)
    }

    public func untransformValue(_ output: Output) throws -> Input {
        try outputClosure(output)
    }

}
