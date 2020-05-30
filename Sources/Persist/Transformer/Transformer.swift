public protocol Transformer {

    associatedtype Input

    associatedtype Output

    func transformValue(_ value: Input) throws -> Output

    func untransformValue(_ value: Output) throws -> Input

}
