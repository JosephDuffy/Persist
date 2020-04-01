import Foundation

internal final class Lock {

    private var unfairLock = os_unfair_lock_s()

    private var spinLock = OS_SPINLOCK_INIT

    internal func perform<ReturnValue>(work: () throws -> ReturnValue) rethrows -> ReturnValue {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            os_unfair_lock_lock(&unfairLock)
            defer {
                os_unfair_lock_unlock(&unfairLock)
            }
            return try work()
        } else {
            OSSpinLockLock(&spinLock)
            defer {
                OSSpinLockUnlock(&spinLock)
            }
            return try work()
        }
    }

}
