public protocol UpdatePropagatingStorage: Storage {

    /**
     Add an update listener that should be notified when a value is updated from an external source, i.e. not via any of the functions on `Storage`.

     - parameter key: The key to subscribe to changes to.
     - parameter updateListener: A closure to call when an update occurs.
     - returns: An object that can be used to remove the update listener and cancel future updates.
     */
    func addUpdateListener(forKey key: String, updateListener: @escaping (Any?) -> Void) -> Cancellable

}
