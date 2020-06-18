import Foundation

struct CodableStruct: Codable, Equatable, ExpressibleByStringLiteral {
    let property: String

    init(property: String) {
        self.property = property
    }

    init(stringLiteral value: String) {
        property = value
    }
}
