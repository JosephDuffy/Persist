/**
 An object that represents a subscription to a `Storage` update.
 */
open class Subscription: Cancellable {
    public static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    /// A closure that will be called when the subscription is cancelled.
    public typealias CancelClosure = () -> Void

    private var cancelClosure: CancelClosure?

    /**
     Create a new subscription that will call the provided closure when cancelled.

     - parameter cancel: The closure to call when the subscription is cancelled.
     */
    public required init(cancel: @escaping CancelClosure) {
        cancelClosure = cancel
    }

    deinit {
        cancel()
    }

    /**
     Cancel the update subscription, preventing further updates being sent to the update listener, freeing any
     resources held on to by the subscription.
     */
    open func cancel() {
        guard let cancelClosure = cancelClosure else { return }
        cancelClosure()
        self.cancelClosure = nil
    }

    open func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}
