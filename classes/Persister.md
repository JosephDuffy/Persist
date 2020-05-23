**CLASS**

# `Persister`

```swift
public final class Persister<Value>
```

## Properties
### `updatesPublisher`

```swift
public var updatesPublisher: AnyPublisher<UpdatePayload, Never>
```

## Methods
### `init(valueGetter:valueSetter:addUpdateListener:)`

```swift
public init(
    valueGetter: @escaping ValueGetter,
    valueSetter: @escaping ValueSetter,
    addUpdateListener: AddUpdateListener
)
```

### `init(key:storedBy:)`

```swift
public convenience init<Storage: Persist.Storage>(
    key: Storage.Key,
    storedBy storage: Storage
) where Storage.Value == Any
```

### `init(key:storedBy:transformer:)`

```swift
public convenience init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
    key: Storage.Key,
    storedBy storage: Storage,
    transformer: Transformer
) where Storage.Value == Any, Transformer.Input == Value
```

### `init(key:storedBy:transformer:)`

```swift
public convenience init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
    key: Storage.Key,
    storedBy storage: Storage,
    transformer: Transformer
) where Transformer.Input == Value, Transformer.Output == Storage.Value
```

### `persist(_:)`

```swift
public func persist(_ newValue: Value?) throws
```

### `retrieveValue()`

```swift
public func retrieveValue() throws -> Value?
```

### `addUpdateListener(_:)`

```swift
public func addUpdateListener(_ updateListener: @escaping UpdateListener) -> Cancellable
```
