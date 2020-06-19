import Foundation

/**
 A transformer that transformers values to JSON data.
 */
public struct JSONTransformer<Input: Codable>: Transformer {

    /// The output of the `JSONTransformer`. Always `Data`.
    public typealias Output = Data

    /// The `JSONEncoder` used for encoding values.
    public var encoder: JSONEncoder

    /// The `JSONDecoder` used to decode values.
    public var decoder: JSONDecoder

    /**
     Create a new instance of `JSONTransformer`.

     - parameter encoder: The encoder used to encode values.
     - parameter decoder: The decoder used to decode values.
     */
    public init(encoder: JSONEncoder = JSONEncoder(), decoder: JSONDecoder = JSONDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }

    /**
     Create a new instance of `JSONTransfomer`, configuring the encoder and decoder with the provided
     user info dictionary.

     - parameter userInfo: The user info dictionary to apply to the encoder and decoder.
     */
    public init(coderUserInfo userInfo: [CodingUserInfoKey: Any]) {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        encoder.userInfo = userInfo
        decoder.userInfo = userInfo

        self.init(encoder: encoder, decoder: decoder)
    }

    /**
     Transformer the provided value to JSON data.

     - parameter value: The value to transform to JSON data.
     - throws: Any error thrown by the encoder.
     - returns: The JSON data.
     */
    public func transformValue(_ value: Input) throws -> Data {
        return try encoder.encode(value)
    }

    /**
     Untransformer the provided JSON data.

     - parameter data: The JSON data to untransform.
     - throws: Any error thrown by the decoder.
     - returns: The untransformed value.
     */
    public func untransformValue(_ data: Data) throws -> Input {
        return try decoder.decode(Input.self, from: data)
    }

}
