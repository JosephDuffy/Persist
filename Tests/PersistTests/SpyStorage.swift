import Persist

internal final class SpyStorage<StoredValue, BackingStorage: Storage>: Storage where BackingStorage.Value == StoredValue {
    typealias Key = BackingStorage.Key

    typealias Value = StoredValue

    private(set) var storeValueCallCount = 0
    private(set) var removeValueCallCount = 0
    private(set) var retrieveValueCallCount = 0
    private(set) var addUpdateListenerCallCount = 0

    private let backingStorage: BackingStorage

    init(backingStorage: BackingStorage) {
        self.backingStorage = backingStorage
    }

    func storeValue(_ value: StoredValue, key: BackingStorage.Key) throws {
        storeValueCallCount += 1

        try backingStorage.storeValue(value, key: key)
    }

    func removeValue(for key: BackingStorage.Key) throws {
        removeValueCallCount += 1

        try backingStorage.removeValue(for: key)
    }

    func retrieveValue(for key: BackingStorage.Key) throws -> StoredValue? {
        retrieveValueCallCount += 1

        return try backingStorage.retrieveValue(for: key)
    }

    func addUpdateListener(forKey key: BackingStorage.Key, updateListener: @escaping UpdateListener) -> Persist.AnyCancellable {
        addUpdateListenerCallCount += 1

        return backingStorage.addUpdateListener(forKey: key, updateListener: updateListener)
    }
}
