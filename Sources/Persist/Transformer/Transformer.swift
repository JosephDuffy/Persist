/**
 A protocol that indicates a type that can perform transformations of values.
 */
public protocol Transformer {

    /// The value that the transformer accepts as an input.
    associatedtype Input

    /// The value the transformer will output.
    associatedtype Output

    /**
     Transform the provided value.

     - parameter value: The value to transform.
     - returns: The transformed value.
     */
    func transformValue(_ value: Input) throws -> Output

    /**
     Untransform the provided value.

     - parameter value: The the value to untransform.
     - returns: The untransformed value.
     */
    func untransformValue(_ value: Output) throws -> Input

}
