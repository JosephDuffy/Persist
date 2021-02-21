import Foundation
import PersistCore

/**
 A transformer that transformers values to property list data.
 */
public struct PropertyListTransformer<Input: Codable>: Transformer {

    /// The output of the `PropertyListTransformer`. Always `Data`.
    public typealias Output = Data

    /// The `PropertyListEncoder` used for encoding values.
    public var encoder: PropertyListEncoder

    /// The `PropertyListDecoder` used for decoding values.
    public var decoder: PropertyListDecoder

    /**
     Create a new instance of `PropertyListTransformer`.

     - parameter encoder: The encoder used to encode values.
     - parameter decoder: The decoder used to decode values.
     */
    public init(encoder: PropertyListEncoder = PropertyListEncoder(), decoder: PropertyListDecoder = PropertyListDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }

    /**
     Create a new instance of `PropertyListTransformer`, configuring the encoder to output the
     property list using the provided format.

     - parameter outputFormat: The format of the property list to output.
     */
    public init(outputFormat: PropertyListSerialization.PropertyListFormat) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = outputFormat

        self.init(encoder: encoder)
    }

    /**
     Create a new instance of `PropertyListTransformer`, configuring the encoder and decoder with
     the provided user info dictionary.

     - parameter userInfo: The user info dictionary to apply to the encoder and decoder.
     */
    public init(coderUserInfo userInfo: [CodingUserInfoKey: Any]) {
        let encoder = PropertyListEncoder()
        let decoder = PropertyListDecoder()
        encoder.userInfo = userInfo
        decoder.userInfo = userInfo

        self.init(encoder: encoder, decoder: decoder)
    }

    /**
     Create a new instance of `PropertyListTransformer`, configuring the encoder and decoder with
     the provided user info dictionary and configuring the encoder to output the property list using the
     provided format.

     - parameter outputFormat: The format of the property list to output.
     - parameter userInfo: The user info dictionary to apply to the encoder and decoder.
     */
    public init(outputFormat: PropertyListSerialization.PropertyListFormat, coderUserInfo userInfo: [CodingUserInfoKey: Any]) {
        let encoder = PropertyListEncoder()
        let decoder = PropertyListDecoder()
        encoder.outputFormat = outputFormat
        encoder.userInfo = userInfo
        decoder.userInfo = userInfo

        self.init(encoder: encoder, decoder: decoder)
    }

    /**
     Transformer the provided value to property list data.

     - parameter value: The value to transform to property list data.
     - throws: Any error thrown by the encoder.
     - returns: The property list data.
     */
    public func transformValue(_ value: Input) throws -> Data {
        return try encoder.encode(value)
    }

    /**
     Untransformer the provided property list data.

     - parameter data: The property list data to untransform.
     - throws: Any error thrown by the decoder.
     - returns: The untransformed value.
     */
    public func untransformValue(_ data: Data) throws -> Input {
        return try decoder.decode(Input.self, from: data)
    }

}
