#if !os(watchOS)
@testable import PersistCore
import XCTest

final class SubscriptionTests: XCTestCase {

    func testDeinitDoesNotCallCancelClosureWhenCancelHasBeenCalled() {
        var cancelCallCount = 0

        do {
            let subscription = Subscription(cancel: { cancelCallCount += 1 })
            subscription.cancel()
        }

        XCTAssertEqual(cancelCallCount, 1, "Must call closure once")
    }

    func testDeinitDoesNotCallCancelClosureForSubsequentCancelCalls() {
        var cancelCallCount = 0
        let subscription = Subscription(cancel: { cancelCallCount += 1 })
        subscription.cancel()

        XCTAssertEqual(cancelCallCount, 1, "Must call closure once")
    }

    func testDeinitCallsCancelClosure() {
        var cancelCallCount = 0

        do {
            _ = Subscription(cancel: { cancelCallCount += 1 })
        }

        XCTAssertEqual(cancelCallCount, 1, "Must call closure once")
    }

    func testEquality() {
        let subscription1 = Subscription(cancel: {})
        let subscription2 = Subscription(cancel: {})

        XCTAssertEqual(subscription1, subscription1, "Subscription must be equal to self")
        XCTAssertNotEqual(subscription1, subscription2, "Subscription must not be equal to other instance")
    }

    func testHashValue() {
        let subscription1 = Subscription(cancel: {})
        let subscription2 = Subscription(cancel: {})

        XCTAssertNotEqual(subscription1.hashValue, subscription2.hashValue, "Subscription hash value must not be equal to other instance")
    }

}
#endif
