import Foundation

public struct CodableStruct: Codable, Equatable, ExpressibleByStringLiteral {
    public let property: String

    public init(property: String) {
        self.property = property
    }

    public init(stringLiteral value: String) {
        property = value
    }
}
