public protocol Subscribable<Key, Value> {
    typealias Key
    typealias Value

    func valuesStream(for key: Key) -> AsyncStream<Value>
}
