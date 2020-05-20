public protocol Transformer {

    associatedtype Input

    associatedtype Output

    func transformValue(_ value: Input) throws -> Output

    func untransformValue(from output: Output) throws -> Input

}
