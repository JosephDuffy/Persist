/**
 A transformer that aggregates multiple transformers. Multiple aggregate transformers can be chained.
 */
public struct AggregateTransformer<Input, Output>: Transformer {

    private let transformValueClosure: (_ value: Input) throws -> Output

    private let untransformValueClosure: (_ value: Output) throws -> Input

    /**
     Creates a new instance of `AggregateTransformer` that will pass values in to `firstTransformer`,
     then pass the output from `firstTransformer` in to `secondTransformer`.

     - parameter firstTransformer: The first transformer to call when transforming values.
     - parameter secondTransformer: The second transformer to call when transforming values.
     */
    public init<FirstTransformer: Transformer, SecondTransformer: Transformer>(
        firstTransformer: FirstTransformer,
        secondTransformer: SecondTransformer
    ) where FirstTransformer.Input == Input, FirstTransformer.Output == SecondTransformer.Input, SecondTransformer.Output == Output {
        transformValueClosure = { value in
            let firstTransform = try firstTransformer.transformValue(value)
            return try secondTransformer.transformValue(firstTransform)
        }

        untransformValueClosure = { value in
            let firstUntransform = try secondTransformer.untransformValue(value)
            return try firstTransformer.untransformValue(firstUntransform)
        }
    }

    /**
     Transform the provided value by passing it to the first transformer, then the second transformer.

     - parameter value: The value to transform
     - throws: Any errors thrown by the transformers.
     - returns: The value returned bt the second transformer.
     */
    public func transformValue(_ value: Input) throws -> Output {
        try transformValueClosure(value)
    }

    /**
     Transform the provided value by passing it to the second transformer, then the first transformer.

     - parameter value: The value to transform
     - throws: Any errors thrown by the transformers.
     - returns: The value returned bt the first transformer.
     */
    public func untransformValue(_ value: Output) throws -> Input {
        return try untransformValueClosure(value)
    }

}

extension Transformer {

    /**
     Create a new transformer that aggregates `self` and the provided transfomer.

     - parameter transformer: The transformer to aggregate with this transformer.
     - returns: The aggregate transformer.
     */
    public func append<Transformer: PersistCore.Transformer>(
        transformer: Transformer
    ) -> AggregateTransformer<Input, Transformer.Output> where Transformer.Input == Output {
        return AggregateTransformer(firstTransformer: self, secondTransformer: transformer)
    }

}
