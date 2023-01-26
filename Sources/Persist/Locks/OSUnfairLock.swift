#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// An `OSUnfairLock` is a wrapper around an unfair lock that locks around
/// accesses to a stored object. It has the same API as `OSAllocatedUnfairLock`.
///
/// Despite being a `struct`, it isn't a value type, as copied instances control
/// the same underlying lock allocation.
///
/// Prefer storing state protected by the lock in `State`. Containing locked
/// state inside the lock helps track what is protected state and provides a
/// scope where it is safe to access that state.
///
/// When using `OSUnfairLock` with external state, nonscoped locking allows more
/// flexible locking patterns by using `lock()` / `unlock()`, but offers no
/// assistance in tracking what state is protected by the lock.
///
/// This lock must be unlocked from the same thread that locked it. As such, it
/// is unsafe to use ``lock()`` / ``unlock()`` across an `await` suspension
/// point. Instead, use ``withLock`` to enforce that the lock is only held
/// within a synchronous scope.
///
/// If you are using a lock from asynchronous contexts only, prefer using an
/// actor instead.
///
/// This lock is not a recursive lock. Attempting to lock it again from the same
/// thread while the lock is already locked will crash.
public struct OSUnfairLock<State>: @unchecked Sendable {
    fileprivate let lockWrapper: SystemLock<State>

    /// Initialize an OSAllocatedUnfairLock with a non-sendable lock-protected
    /// `initialState`.
    ///
    /// By initializing with a non-sendable type, the owner of this structure
    /// must ensure the Sendable contract is upheld manually.
    /// Non-sendable content from `State` should not be allowed
    /// to escape from the lock.
    ///
    /// - Parameter initialState: An initial value to store that will be
    ///  protected under the lock.
    ///
    public init(uncheckedState initialState: State) {
        lockWrapper = SystemLock(uncheckedState: initialState)
    }

    ///  Perform a closure while holding this lock.
    ///  This method does not enforce sendability requirement
    ///  on closure body and its return type.
    ///  The caller of this method is responsible for ensuring references
    ///   to non-sendables from closure uphold the Sendability contract.
    ///
    /// - Parameter body: A closure to invoke while holding this lock.
    /// - Returns: The return value of `body`.
    /// - Throws: Anything thrown by `body`.
    ///
    public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        lockWrapper.lock()
        defer {
            lockWrapper.unlock()
        }
        return try body(&lockWrapper.state)
    }

    ///  Perform a sendable closure while holding this lock.
    ///
    /// - parameter body: A sendable closure to invoke while holding this lock.
    /// - returns: The sendable return value of `body`.
    /// - throws: Anything thrown by `body`.
    public func withLock<R>(
        // swiftformat:disable:next spaceAroundParens
        _ body: @Sendable (inout State) throws -> R
    ) rethrows -> R where R: Sendable {
        lockWrapper.lock()
        defer {
            lockWrapper.unlock()
        }
        return try body(&lockWrapper.state)
    }

    ///  Attempt to acquire the lock, if successful, perform a closure while
    ///  holding the lock.
    ///  This method does not enforce sendability requirement
    ///  on closure body and its return type.
    ///  The caller of this method is responsible for ensuring references
    ///   to non-sendables from closure uphold the Sendability contract.
    ///
    /// - Parameter body: A closure to invoke while holding this lock.
    /// - Returns: If the lock is acquired, the result of `body`.
    ///            If the lock is not acquired, nil.
    /// - Throws: Anything thrown by `body`.
    ///
    public func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R? {
        let didLock = lockWrapper.lockIfAvailable()
        guard didLock else { return nil }

        defer {
            lockWrapper.unlock()
        }
        return try body(&lockWrapper.state)
    }

    ///  Attempt to acquire the lock, if successful, perform a sendable closure while
    ///  holding the lock.
    ///
    /// - Parameter body: A closure to invoke while holding this lock.
    /// - Returns: If the lock is acquired, the result of `body`.
    ///            If the lock is not acquired, nil.
    /// - Throws: Anything thrown by `body`.
    ///
    public func withLockIfAvailable<R>(_ body: @Sendable (inout State) throws -> R) rethrows -> R? where R : Sendable {
        let didLock = lockWrapper.lockIfAvailable()
        guard didLock else { return nil }

        defer {
            lockWrapper.unlock()
        }
        return try body(&lockWrapper.state)
    }

    #if canImport(Darwin)
    /// Check a precondition about whether the calling thread is the lock owner.
    ///
    /// - Parameter condition: An `Ownership` statement to check for the
    /// current context.
    /// - If the lock is currently owned by the calling thread:
    ///   - `.owner` - returns
    ///   - `.notOwner` - asserts and terminates the process
    /// - If the lock is unlocked or owned by a different thread:
    ///   - `.owner` - asserts and terminates the process
    ///   - `.notOwner` - returns
    ///
    public func precondition(_ condition: Ownership) {
        switch condition {
        case .owner:
            lockWrapper.assertOwner()
        case .notOwner:
            lockWrapper.assertNotOwner()
        }
    }
    #endif
}

#if canImport(Darwin)
extension OSUnfairLock {
    /// Represent ownership status for `precondition` checking.
    public enum Ownership: Hashable, Sendable {
        /// Lock is currently owned by the calling thread.
        case owner

        /// Lock is unlocked or owned by a different thread.
        case notOwner
    }
}
#endif

extension OSUnfairLock where State == Sendable {
    /// Initialize an OSAllocatedUnfairLock with a lock-protected sendable
    /// `initialState`.
    /// - Parameter initialState: An initial value to store that will be
    ///   protected under the lock.
    public init(initialState: State) {
        self.init(uncheckedState: initialState)
    }
}

extension OSUnfairLock where State == Void {
    /// Initialize an OSAllocatedUnfairLock with no protected state.
    public init() {
        self.init(uncheckedState: ())
    }

    public func withLock<R>(
        // swiftformat:disable:next spaceAroundParens
        _ body: @Sendable () throws -> R
    ) rethrows -> R where R: Sendable {
        lockWrapper.lock()
        defer {
            lockWrapper.unlock()
        }
        return try body()
    }

    /// Acquire this lock.
    public func lock() {
        lockWrapper.lock()
    }

    /// Unlock this lock.
    public func unlock() {
        lockWrapper.unlock()
    }

    /// Attempt to acquire the lock if it is not already locked.
    ///
    /// - Returns: `true` if the lock was succesfully locked, and
    ///  `false` if the lock attempt failed.
    public func lockIfAvailable() -> Bool {
        lockWrapper.lockIfAvailable()
    }
}

#if canImport(Darwin)
/// A lock backed by `os_unfair_lock`. This will be used on Apple platforms.
private final class SystemLock<State> {
    fileprivate let lockPointer: UnsafeMutablePointer<os_unfair_lock>

    fileprivate var state: State

    init(uncheckedState initialState: State) {
        lockPointer = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        lockPointer.initialize(to: os_unfair_lock())
        state = initialState
    }

    deinit {
        lockPointer.deinitialize(count: 1)
        lockPointer.deallocate()
    }

    /// Acquire this lock.
    func lock() {
        os_unfair_lock_lock(lockPointer)
    }

    /// Unlock this lock.
    func unlock() {
        os_unfair_lock_unlock(lockPointer)
    }

    /// Attempt to acquire the lock if it is not already locked.
    ///
    /// - Returns: `true` if the lock was succesfully locked, and
    ///  `false` if the lock attempt failed.
    func lockIfAvailable() -> Bool {
        os_unfair_lock_trylock(lockPointer)
    }

    func assertOwner() {
        os_unfair_lock_assert_owner(lockPointer)
    }

    func assertNotOwner() {
        os_unfair_lock_assert_not_owner(lockPointer)
    }
}
#else
/// A lock backed by `pthread_mutex_t`. This will be used on Linux.
private final class SystemLock<State> {
    private let mutexPointer: UnsafeMutablePointer<pthread_mutex_t>

    fileprivate var state: State

    init(uncheckedState initialState: State) {
        var mutexAttributes = pthread_mutexattr_t()
        pthread_mutexattr_init(&mutexAttributes)

        let mutexPointer = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)

        let initResult = pthread_mutex_init(mutexPointer, &mutexAttributes)
        precondition(initResult == 0, "Failed to initialise mutex with error \(initResult)")
        pthread_mutexattr_destroy(&mutexAttributes)

        self.mutexPointer = mutexPointer
        state = initialState
    }

    deinit {
        let destroyResult = pthread_mutex_destroy(self.mutexPointer)
        precondition(destroyResult == 0, "Failed to destroy mutex with error \(destroyResult)")
        mutexPointer.deallocate()
    }

    /// Acquire this lock.
    func lock() {
        let lockResult = pthread_mutex_lock(mutexPointer)
        precondition(lockResult == 0, "Failed to lock lock with error \(lockResult)")
    }

    /// Unlock this lock.
    func unlock() {
        let unlockResult = pthread_mutex_unlock(mutexPointer)
        precondition(unlockResult == 0, "Failed to unlock lock with error \(unlockResult)")
    }

    /// Attempt to acquire the lock if it is not already locked.
    ///
    /// - Returns: `true` if the lock was succesfully locked, and
    ///  `false` if the lock attempt failed.
    func lockIfAvailable() -> Bool {
        pthread_mutex_trylock(mutexPointer) == 0
    }
}
#endif
