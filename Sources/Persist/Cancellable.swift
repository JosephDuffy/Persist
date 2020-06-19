/**
 A protocol indicating that a update listener can be cancelled.

 Implementations of this protocol must call the `cancel` function on `deinit`.
 */
public protocol Cancellable: class {
    /**
     Stop further updates being sent to the update listener, freeing any resources held on to by the
     subscription.
     */
    func cancel()
}
