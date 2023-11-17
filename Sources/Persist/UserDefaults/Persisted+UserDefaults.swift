//#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
//import Foundation
//
//// MARK: - Value: StorableInUserDefaults
//
//extension Persisted {
//    public init(
//        wrappedValue: Value,
//        key: String,
//        userDefaults: UserDefaults,
//        defaultValuePersistBehaviour: DefaultValuePersistOption = []
//    ) where Value: StorableInUserDefaults, Storage == TransformedStorage<String, Value> {
//        self.init(
//            wrappedValue: wrappedValue,
//            key: key,
//            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
//            transformer: StorableInUserDefaultsTransformer<Value>(),
//            defaultValuePersistBehaviour: defaultValuePersistBehaviour
//        )
//    }
//
//    public init<WrappedValue>(
//        wrappedValue: WrappedValue? = nil,
//        key: String,
//        userDefaults: UserDefaults,
//        defaultValuePersistBehaviour: DefaultValuePersistOption = []
//    ) where WrappedValue: StorableInUserDefaults, Value == WrappedValue?, Storage == TransformedStorage<String, Value> {
//        self.init(
//            wrappedValue: wrappedValue,
//            key: key,
//            storedBy: UserDefaultsStorage(userDefaults: userDefaults),
//            transformer: StorableInUserDefaultsTransformer<WrappedValue>(),
//            defaultValuePersistBehaviour: defaultValuePersistBehaviour
//        )
//    }
//}
//#endif
