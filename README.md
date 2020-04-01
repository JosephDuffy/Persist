# Persist

Property wrapper for automatic thread-safe storage and retrieval of values.

## Usage

Persist provides the `Persisted` property wrapper, which handles the automatic persistence and retrieval of values by utilising the `Persister`. When creating a `Persisted` property wrapper any form of storage may be used. Included with `Persist` is an extension to `UserDefaults` to support persistence.

```swift
class Foo {
    @Persisted(key: "foo-bar", storage: UserDefaults.standard)
    var bar: String?
}

let foo = Foo()
foo.bar // nil
foo.bar = "new-value"
UserDefaults.standard.object(forKey: "foo-bar") // "new-value"
```

### Subscribing to Updates

When targeting macOS 10.15, iOS 13, tvOS 13, or watchOS 6 or greater Combine can be used to subscribe to updates:

```swift
class Foo {
    @Persisted
    var bar: String?
}

let foo = Foo()
let cancellable = foo.$bar.updatesPublisher.sink { _ in
    print("Value updated")
}
```

For versions prior to macOS 10.15, iOS 13, tvOS 13, or watchOS 6 a closure API is provided:

```swift
class Foo {
    @Persisted
    var bar: String?
}

let foo = Foo()
let cancellable = foo.$bar.addUpdateListener() { _ in
    print("Value updated")
}
```

## Dependency Injection

To support testing you may initialise the property wrapper in your own init functions, e.g.:

```swift
class Foo {
    @Persisted
    var bar: String?

    init() {
        _persisted = Persisted(key: "foo-bar", storage: UserDefaults.standard)
    }
}
```
