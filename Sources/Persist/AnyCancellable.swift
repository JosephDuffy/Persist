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
