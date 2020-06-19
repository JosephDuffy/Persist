/**
 An object that represents a subscription to a `Storage` update.
 */
public final class Subscription: Cancellable {

    internal typealias CancelClosure = () -> Void

    private var cancelClosure: CancelClosure?

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
    public func cancel() {
        guard let cancelClosure = cancelClosure else { return }
        cancelClosure()
        self.cancelClosure = nil
    }

}
