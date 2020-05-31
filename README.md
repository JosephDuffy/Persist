# Persist

[![Tests](https://github.com/JosephDuffy/Persist/workflows/Tests/badge.svg)](https://github.com/JosephDuffy/Persist/actions?query=workflow%3ATests)
[![codecov](https://codecov.io/gh/JosephDuffy/Persist/branch/master/graph/badge.svg)](https://codecov.io/gh/JosephDuffy/Persist)
[![Documentation](https://josephduffy.github.io/Persist/badge.svg)](https://josephduffy.github.io/Persist/)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

`Persist` is a framework that aids with storing and retrieving values, with support for transformations such as storing as JSON data.

## Usage

Persist provides the `Persister` class, which can be used to store and retieve values from various forms of storage.

The `Persisted` property wrapper wraps `Persister`, making it easy to have a property that automatically persists its value.

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

- `UserDefaults`
- `NSUbiquitousKeyValueStore`
- `FileManager`
- `InMemoryStorage` (a simple wrapper around a dictionary)

### Catching Errors

`Persister`'s `persist(_:)` and `retrieveValue()` functions will throw if the storage or transformer throws are error.

`Persited` wraps a `Persister` and exposes it as the `projectedValue`, which allows you to catch errors:

```swift
class Foo {
    @Persisted(key: "foo-bar", userDefaults: .standard)
    var bar: String?
}

do {
    let foo = Foo()
    try foo.$bar.persist("new-value")
    try foo.$bar.retrieveValue()
} catch {
    // Something went wrong
}
```

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

let foo = Foo()
let cancellable = foo.$bar.addUpdateListener() { updateResult in
    switch updateResult {
    case .success(let bar):
        // `bar` is always `Bar?` despite being transformed to JSON `Data` by `JSONTransformer`
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

    public func untransformValue(_ bar: Bar) -> Bar {
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

### Default Values

A default value may be provided that will be used when the persister returns `nil` or throws and error.

```swift
struct Foo {
    @Persisted(key: "bar", userDefaults: .standard, defaultValue: "default")
    var bar: Bar!
}

var foo = Foo()
foo.bar // "default"
```

The default value can be optionally stored when used, either due to an error or because the storage returned `nil`. This can be useful when the first value is random and should be persisted between app launches once initially created.

```swift
struct Foo {
    @Persisted(key: "persistedWhenNilInt", userDefaults: .standard, defaultValue: Int.random(in: 1...10), defaultValuePersistBehaviour: .persistWhenNil)
    var persistedWhenNilInt: Int!

    @Persisted(key: "notPersistedWhenNilRandomInt", userDefaults: .standard, defaultValue: Int.random(in: 1...10))
    var notPersistedWhenNilRandomInt: Int!
}

var foo = Foo()

UserDefaults.standard.object(forKey: "persistedWhenNilInt") // nil
foo.persistedWhenNilInt // 3
UserDefaults.standard.object(forKey: "persistedWhenNilInt") // 3
foo.persistedWhenNilInt // 3

UserDefaults.standard.object(forKey: "notPersistedWhenNilRandomInt") // nil
foo.notPersistedWhenNilRandomInt // 7
UserDefaults.standard.object(forKey: "notPersistedWhenNilRandomInt") // nil
foo.notPersistedWhenNilRandomInt // 7

// ...restart app

UserDefaults.standard.object(forKey: "persistedWhenNilInt") // 3
foo.persistedWhenNilInt // 3

UserDefaults.standard.object(forKey: "notPersistedWhenNilRandomInt") // nil
foo.notPersistedWhenNilRandomInt // 4
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

# License

The project is released under the MIT license. View the [LICENSE](./LICENSE) file for the full license.
