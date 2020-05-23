# Persist

[![codecov](https://codecov.io/gh/JosephDuffy/Persist/branch/master/graph/badge.svg)](https://codecov.io/gh/JosephDuffy/Persist)

Property wrapper for storing and retrieving values with support for transformations such as storing as JSON data.

## Usage

Persist provides the `Persisted` property wrapper, which handles the persisting of values by utilising some form of storage. When creating a `Persisted` property wrapper any form of storage may be used, as long as it supports the type you wish to store.

```swift
class Foo {
    @Persisted(key: "foo-bar", userDefaults: .standard)
    var bar: String?
}

let foo = Foo()
foo.bar // nil
foo.bar = "new-value"
UserDefaults.standard.object(forKey: "foo-bar") // "new-value"
```

`Persist` includes out-of-the-box supports for:

- [x] `UserDefaults`
- [ ] `NSUbiquitousKeyValueStore`
- [ ] Local file system
- [ ] Keychain
- [x] `InMemoryStorage` (a simple wrapper around a dictionary)

### Subscribing to Updates

When targeting macOS 10.15, iOS 13, tvOS 13, or watchOS 6 or greater Combine can be used to subscribe to updates:

```swift
class Foo {
    @Persisted(key: "foo-bar", userDefaults: .standard)
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
    @Persisted(key: "foo-bar", userDefaults: .standard)
    var bar: String?
}

let foo = Foo()
let cancellable = foo.$bar.addUpdateListener() { _ in
    print("Value updated")
}
```

### Transformers

Some storage methods will only support a subset of types, or you might want to modify how some values are encoded/decoded (e.g. to ensure on-disk date representation are the same as what an API sends/expects). This is where transformers come in:

```swift
struct Bar: Codable {
    var baz: String
}

class Foo {
    @Persisted(key: "bar", userDefaults: .standard, transformer: JSONTransformer())
    var bar: Bar?
}
```

When using a transformer subscribers will always be notified of the pre-encoded and post-decoded value:

```swift
let foo = Foo()
let cancellable = foo.$bar.addUpdateListener() { updateResult in
    switch updateResult {
    case .success(let bar):
        // `bar` is always `Bar?` despite being stored as JSON `Data`
        print("Bar updated:", bar ?? "removed")
    case .failure(let error):
        print("Error updating bar:", error)
    }
}
```

Transformers are typesafe, e.g. `JSONTransformer` is only usable when the value to be stored is `Codable` and the `Storage` supports `Data`.

#### Chaining Transformers

If a value should go through mutliple transformers you can chain them.

```swift
struct Bar: Codable {
    var baz: String
}

public struct BarTransformer: Transformer {

    public func transformValue(_ bar: Bar) -> Bar {
        var bar = bar
        bar.baz = "transformed"
        return bar
    }

    public func untransformValue(from bar: Bar) -> Bar {
        return bar
    }

}

class Foo {
    @Persisted(key: "bar", userDefaults: .standard, transformer: BarTransformer().append(JSONTransformer()))
    var bar: Bar?
}

let foo = Foo()
let bar = Bar(baz: "example value")
foo.bar = bar
foo.bar.baz // "transformed"
```

### Property Wrapper Initialisation

To support dependency injection or to initialise more complex `Persisted` instances you may initialise the property wrapper in your own init functions:

```swift
class Foo {
    @Persisted
    var bar: String?

    init(userDefaults: UserDefaults) {
        _bar = Persisted(key: "foo-bar", userDefaults: userDefaults)
    }
}
```

## Installation

Persist can be installed via [SwiftPM](https://github.com/apple/swift-package-manager) by adding the package to the dependencies section and as the dependency of a target:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/JosephDuffy/Persist.git", from: "0.1.0"),
    ],
    targets: [
        .target(name: "MyApp", dependencies: ["Persist"]),
    ],
    ...
)
```
