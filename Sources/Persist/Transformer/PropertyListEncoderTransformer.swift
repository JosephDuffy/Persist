import Foundation

public struct PropertyListEncoderTransformer<Input: Codable>: Transformer {

    public typealias Output = Data

    public var encoder: PropertyListEncoder

    public var decoder: PropertyListDecoder

    public init(encoder: PropertyListEncoder = PropertyListEncoder(), decoder: PropertyListDecoder = PropertyListDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }

    public init(outputFormat: PropertyListSerialization.PropertyListFormat) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = outputFormat

        self.init(encoder: encoder)
    }

    public init(coderUserInfo userInfo: [CodingUserInfoKey: Any]) {
        let encoder = PropertyListEncoder()
        let decoder = PropertyListDecoder()
        encoder.userInfo = userInfo
        decoder.userInfo = userInfo

        self.init(encoder: encoder, decoder: decoder)
    }

    public init(outputFormat: PropertyListSerialization.PropertyListFormat, userInfo: [CodingUserInfoKey: Any]) {
        let encoder = PropertyListEncoder()
        let decoder = PropertyListDecoder()
        encoder.outputFormat = outputFormat
        encoder.userInfo = userInfo
        decoder.userInfo = userInfo

        self.init(encoder: encoder, decoder: decoder)
    }

    public func transformValue(_ value: Input) throws -> Data {
        return try encoder.encode(value)
    }

    public func untransformValue(from data: Data) throws -> Input {
        return try decoder.decode(Input.self, from: data)
    }

}
