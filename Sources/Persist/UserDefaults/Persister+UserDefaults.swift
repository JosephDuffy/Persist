//#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//import Foundation
//
//// MARK: - Value: StorableInUserDefaults
//
//extension Persister where Value: StorableInUserDefaults, Storage == TransformedStorage<String, Value> {
//    /**
//     Create a new instance that stores the value against the `key`, storing values in the specified
//     `UserDefaults`, defaulting to `defaultValue`.
//
//     - parameter key: The key to store the value against
//     - parameter userDefaults: The user defaults to use to persist and retrieve the value.
//     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs.
//     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
//     */
//    public convenience init(
//        key: String,
//        userDefaults: UserDefaults,
//        defaultValue: @autoclosure @escaping () -> Value,
//        defaultValuePersistBehaviour: DefaultValuePersistOption = []
//    ) {
//        self.init(
//            key: key,
//            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
//            transformer: StorableInUserDefaultsTransformer<Value>(),
//            defaultValue: defaultValue(),
//            defaultValuePersistBehaviour: defaultValuePersistBehaviour
//        )
//    }
//}
//#endif
