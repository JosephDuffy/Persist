/**
 An object that represents a subscription to a `Storage` update.
 */
internal class Subscription: Cancellable {
    internal static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    /// A closure that will be called when the subscription is cancelled.
    internal typealias CancelClosure = () -> Void

    private var cancelClosure: CancelClosure?

    /**
     Create a new subscription that will call the provided closure when cancelled.

     - parameter cancel: The closure to call when the subscription is cancelled.
     */
    internal init(cancel: @escaping CancelClosure) {
        cancelClosure = cancel
    }

    deinit {
        cancel()
    }

    /**
     Cancel the update subscription, preventing further updates being sent to the update listener, freeing any
     resources held on to by the subscription.
     */
    internal func cancel() {
        guard let cancelClosure = cancelClosure else { return }
        cancelClosure()
        self.cancelClosure = nil
    }

    internal func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }
}
