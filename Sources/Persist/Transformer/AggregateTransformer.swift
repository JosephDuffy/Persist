public struct AggregateTransformer<Input, Output>: Transformer {

    private let transformValueClosure: (_ value: Input) throws -> Output

    private let untransformValueClosure: (_ value: Output) throws -> Input

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

    public func transformValue(_ value: Input) throws -> Output {
        try transformValueClosure(value)
    }

    public func untransformValue(_ value: Output) throws -> Input {
        return try untransformValueClosure(value)
    }

}

extension Transformer {

    public func append<Transformer: Persist.Transformer>(
        transformer: Transformer
    ) -> AggregateTransformer<Input, Transformer.Output> where Transformer.Input == Output {
        return AggregateTransformer(firstTransformer: self, secondTransformer: transformer)
    }

}
