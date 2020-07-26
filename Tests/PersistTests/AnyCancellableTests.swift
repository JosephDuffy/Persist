#if !os(watchOS)
@testable import Persist
import XCTest

final class AnyCancellableTests: XCTestCase {

    func testEqualsFunctionWithSameWrappedTypeCallsWrappedEquals() {
        let wrapped = MockCancellable()
        let wrapped2 = MockCancellable()
        let anyCancellable = wrapped.eraseToAnyCancellable()
        let anyCancellable2 = wrapped2.eraseToAnyCancellable()

        _ = anyCancellable == anyCancellable2

        XCTAssertEqual(wrapped.equalsCallCount, 1, "Must call == once")
        XCTAssertEqual(wrapped2.equalsCallCount, 1, "Must call == once")
    }

    func testEqualsFunctionWithDifferentWrappedTypeDoesNotCallWrappedEquals() {
        let wrapped = MockCancellable()
        let wrapped2 = Subscription(cancel: {})
        let anyCancellable = wrapped.eraseToAnyCancellable()
        let anyCancellable2 = wrapped2.eraseToAnyCancellable()

        _ = anyCancellable == anyCancellable2

        XCTAssertEqual(wrapped.equalsCallCount, 0, "Must not call ==")
    }

    func testCancelFunctionCallsWrappedCancel() {
        let wrapped = MockCancellable()
        let anyCancellable = wrapped.eraseToAnyCancellable()
        anyCancellable.cancel()

        XCTAssertEqual(wrapped.cancelCallCount, 1, "Must call cancel once")
    }

    func testHashFunctionCallsWrappedHash() {
        let wrapped = MockCancellable()
        let anyCancellable = wrapped.eraseToAnyCancellable()
        _ = anyCancellable.hashValue

        XCTAssertEqual(wrapped.hashCallCount, 1, "Must call cancel once")
    }

    func testDeinitDoesNotCallWrappedCancel() {
        let wrapped = MockCancellable()
        var anyCancellable: AnyCancellable? = wrapped.eraseToAnyCancellable()
        _ = anyCancellable
        anyCancellable = nil

        XCTAssertEqual(wrapped.cancelCallCount, 0, "Must not call cancel")
    }

}

private final class MockCancellable: Cancellable {
    static func == (lhs: MockCancellable, rhs: MockCancellable) -> Bool {
        lhs.equalsCallCount += 1
        rhs.equalsCallCount += 1
        return lhs === rhs
    }

    private(set) var equalsCallCount = 0
    private(set) var cancelCallCount = 0
    private(set) var hashCallCount = 0

    func cancel() {
        cancelCallCount += 1
    }

    func hash(into hasher: inout Hasher) {
        hashCallCount += 1
        ObjectIdentifier(self).hash(into: &hasher)
    }
}
#endif
