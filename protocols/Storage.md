**PROTOCOL**

# `Storage`

```swift
public protocol Storage: class
```

> A protocol that defines the interface to store, remove, and retrieve values by a string key.

## Methods
### `storeValue(_:key:)`

```swift
func storeValue(_ value: Value, key: Key) throws
```

> Store the provided value against the provided key.
>
> - parameter value: The value to store.
> - parameter key: The key to store the value against.

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to store. |
| key | The key to store the value against. |

### `removeValue(for:)`

```swift
func removeValue(for key: Key) throws
```

> Remove the value for the provided key.
>
> - parameter key: The key of the value to remove.

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The key of the value to remove. |

### `retrieveValue(for:)`

```swift
func retrieveValue(for key: Key) throws -> Value?
```

> Retrieve the value for the provided key.
>
> - throws: `PersistanceError.unexpectedValueType` if stored value that is not of type `Value`.
> - parameter key: The key of the value to retrieve.
> - returns: The stored value, or `nil` if no value is associated with the key.

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The key of the value to retrieve. |

### `addUpdateListener(forKey:updateListener:)`

```swift
func addUpdateListener(forKey key: Key, updateListener: @escaping UpdateListener) -> Cancellable
```

> Add an update listener that should be notified when a value is updated from an external source, i.e. not via any of the functions on `Storage`.
>
> - parameter key: The key to subscribe to changes to.
> - parameter updateListener: A closure to call when an update occurs.
> - returns: An object that can be used to remove the update listener and cancel future updates.

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The key to subscribe to changes to. |
| updateListener | A closure to call when an update occurs. |