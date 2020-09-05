import Foundation
import PersistCore

/// A Transformer that transforms `RawRepresentable` types.
public struct RawRepresentableTransformer<Type: RawRepresentable>: Transformer {
    public typealias Output = Type.RawValue

    /// An error thown when untransforming a value.
    public enum UntransformError: LocalizedError {
        /// The raw value could not be used to construct a value of `Type`.
        case invalidRawValue(Type.RawValue)

        public var errorDescription: String? {
            switch self {
            case .invalidRawValue(let rawValue):
                return "\(rawValue) is not a valid value for \(Type.self)"
            }
        }
    }

    public init() {}

    public func transformValue(_ value: Type) -> Type.RawValue {
        value.rawValue
    }

    public func untransformValue(_ rawValue: Type.RawValue) throws -> Type {
        guard let value = Type(rawValue: rawValue) else {
            throw UntransformError.invalidRawValue(rawValue)
        }
        return value
    }
}
