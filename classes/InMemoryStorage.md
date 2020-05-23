**CLASS**

# `InMemoryStorage`

```swift
open class InMemoryStorage: Storage
```

> Storage that stores values in memory; values will not be persisted between app launches or instances of `InMemoryStorage`.

## Methods
### `init()`

```swift
public init()
```

### `storeValue(_:key:)`

```swift
open func storeValue(_ value: Any, key: String)
```

### `removeValue(for:)`

```swift
open func removeValue(for key: String)
```

### `retrieveValue(for:)`

```swift
open func retrieveValue(for key: String) -> Any?
```

### `addUpdateListener(forKey:updateListener:)`

```swift
open func addUpdateListener(forKey key: String, updateListener: @escaping UpdateListener) -> Cancellable
```
