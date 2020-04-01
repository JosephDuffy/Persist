public final class Cancellable {

    public typealias CancelClosure = () -> Void

    private var cancelClosure: CancelClosure?

    public init(cancel: @escaping CancelClosure) {
        cancelClosure = cancel
    }

    deinit {
        cancel()
    }

    public func cancel() {
        cancelClosure?()
        cancelClosure = nil
    }

}
