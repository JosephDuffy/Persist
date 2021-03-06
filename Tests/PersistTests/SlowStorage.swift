#if !os(watchOS)
import Persist
import Foundation

/**
 Storage that only persists value in memory and allows for artificial slowdowns.
 */
public final class SlowStorage<StoredValue>: InMemoryStorage<StoredValue> {

    public var storeDelay: useconds_t?

    public var removeDelay: useconds_t?

    public var retrieveDelay: useconds_t?

    public override func storeValue(_ value: StoredValue, key: String) {
        _ = storeDelay.map(usleep)

        super.storeValue(value, key: key)
    }

    public override func removeValue(for key: String) {
        _ = removeDelay.map(usleep)

        super.removeValue(for: key)
    }

    public override func retrieveValue(for key: String) -> StoredValue? {
        _ = retrieveDelay.map(usleep)

        return super.retrieveValue(for: key)
    }

}
#endif
