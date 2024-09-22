/// A concrete implementation of the `Cancellable` protocol.
public final class AnyCancellable: Cancellable {
    public static func == (lhs: AnyCancellable, rhs: AnyCancellable) -> Bool {
        lhs._isEqual(rhs)
    }

    private let _isEqual: (_ rhs: AnyCancellable) -> Bool

    private let _cancel: () -> Void

    private let _hash: (_ hasher: inout Hasher) -> Void

    private let cancellable: Any

    /// Initialise a new `AnyCancellable` that wraps the provided cancellable.
    ///
    /// This object will **not** call `cancel` when deinitialised to allow the wrapped `Cancellable`
    /// to be stored independently of the wrapper.
    ///
    /// - Parameter cancellable: The `Cancellable` to wrap.
    public init<Cancellable: Persist.Cancellable>(_ cancellable: Cancellable) {
        _isEqual = { rhs in
            guard let rhsCancellable = rhs.cancellable as? Cancellable else { return false }
            return cancellable == rhsCancellable
        }
        _cancel = {
            cancellable.cancel()
        }
        _hash = { hasher in
            cancellable.hash(into: &hasher)
        }
        self.cancellable = cancellable
    }

    public func cancel() {
        _cancel()
    }

    public func hash(into hasher: inout Hasher) {
        _hash(&hasher)
    }
}

extension Cancellable {
    /// Initialise any return a new `AnyCancellable` that wraps this `Cancellable` instance.
    ///
    /// - Returns: The `AnyCancellable` that wraps this `Canellable`.
    public func eraseToAnyCancellable() -> AnyCancellable {
        return AnyCancellable(self)
    }
}

/**
 A protocol indicating that a update listener can be cancelled.

 Implementations of this protocol must call the `cancel` function on `deinit`.
 */
public protocol Cancellable: AnyObject, Hashable {
    /**
     Stop further updates being sent to the update listener, freeing any resources held on to by the
     subscription.
     */
    func cancel()
}

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
