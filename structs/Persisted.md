**STRUCT**

# `Persisted`

```swift
public struct Persisted<Value>
```

## Properties
### `wrappedValue`

```swift
public var wrappedValue: Value?
```

### `projectedValue`

```swift
public private(set) var projectedValue: Persister<Value>
```

### `defaultValue`

```swift
public let defaultValue: Value?
```

## Methods
### `init(persister:defaultValue:)`

```swift
public init(persister: Persister<Value>, defaultValue: Value? = nil)
```

### `init(key:defaultValue:storedBy:)`

```swift
public init<Storage: Persist.Storage>(
    key: Storage.Key,
    defaultValue: Value? = nil,
    storedBy storage: Storage
) where Storage.Value == Any
```

### `init(key:defaultValue:storedBy:transformer:)`

```swift
public init<Storage: Persist.Storage, Transformer: Persist.Transformer>(
    key: Storage.Key,
    defaultValue: Value? = nil,
    storedBy storage: Storage,
    transformer: Transformer
) where Transformer.Input == Value, Transformer.Output == Storage.Value
```
