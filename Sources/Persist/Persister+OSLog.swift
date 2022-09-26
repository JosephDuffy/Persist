#if canImport(os)
import os.log
import PersistLogger

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
extension Persister {
    /**
     Create a new `Persister` instance.

     - parameter valueGetter: The closure that will be called when the `retrieveValue()` function is called.
     - parameter valueSetter: The closure that will be called when the `persist(_:)` function is called.
     - parameter valueRemover: The closure that will be called when the `removeValue()` function is called.
     - parameter defaultValue: The value to use when a value has not yet been stored, or an error occurs. This value is lazily evaluated.
     - parameter defaultValuePersistBehaviour: An option set that describes when to persist the default value. Defaults to `[]`.
     - parameter addUpdateListener: A closure that will be called immediately to add an update listener.
     */
    public convenience init(
        valueGetter: @escaping ValueGetter,
        valueSetter: @escaping ValueSetter,
        valueRemover: @escaping ValueRemover,
        defaultValue: @autoclosure @escaping () -> Value,
        defaultValuePersistBehaviour: DefaultValuePersistOption = [],
        osLog: OSLog,
        addUpdateListener: AddUpdateListener
    ) {
        let logger = OSLogPersistLogger(log: osLog)
        self.init(valueGetter: valueGetter, valueSetter: valueSetter, valueRemover: valueRemover, defaultValue: defaultValue(), defaultValuePersistBehaviour: defaultValuePersistBehaviour, logger: logger, addUpdateListener: addUpdateListener)
    }
}
#endif
