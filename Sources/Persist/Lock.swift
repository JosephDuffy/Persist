import Foundation

public final class FairLock: Lock {

    private var queue: DispatchQueue = DispatchQueue(label: "lock")

    public func perform<ReturnValue>(work: () throws -> ReturnValue) rethrows -> ReturnValue {
        return try queue.sync(execute: work)
    }

}

public protocol Lock {
    func perform<ReturnValue>(work: () throws -> ReturnValue) rethrows -> ReturnValue
}

public final class UnfairLock: Lock {

    private lazy var unfairLock = os_unfair_lock_s()

    private lazy var spinLock = OS_SPINLOCK_INIT

    public func perform<ReturnValue>(work: () throws -> ReturnValue) rethrows -> ReturnValue {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            os_unfair_lock_lock(&unfairLock)
            do {
                let result = try work()
                os_unfair_lock_unlock(&unfairLock)
                return result
            } catch {
                os_unfair_lock_unlock(&unfairLock)
                throw error
            }
        } else {
            OSSpinLockLock(&spinLock)
            do {
                let result = try work()
                OSSpinLockUnlock(&spinLock)
                return result
            } catch {
                OSSpinLockUnlock(&spinLock)
                throw error
            }
        }
    }
}
