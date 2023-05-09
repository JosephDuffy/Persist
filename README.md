# Persist

[![Tests](https://github.com/JosephDuffy/Persist/workflows/Tests/badge.svg)](https://github.com/JosephDuffy/Persist/actions?query=workflow%3ATests)
![Supported Xcode Versions](https://img.shields.io/badge/Xcode-13.4.1%20%7C%2014.2-success)<!---xcode-version-badge-markdown-->
[![codecov](https://codecov.io/gh/JosephDuffy/Persist/branch/master/graph/badge.svg)](https://codecov.io/gh/JosephDuffy/Persist)
[![Documentation](https://josephduffy.github.io/Persist/badge.svg)](https://josephduffy.github.io/Persist/)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

`Persist` is a framework that aids with persisting and retrieving values, with support for transformations such as storing as JSON data.

## Usage

Persist provides the `Persister` class, which can be used to persist and retrieve values from various forms of storage.

The `Persisted` property wrapper wraps a `Persister`, making it easy to have a property that automatically persists its value.

```swift
class Foo {
    enum Bar: Int {
        case firstBar = 1
        case secondBar = 2
    }

    @Persisted(key: "foo-bar", userDefaults: .standard, transformer: RawRepresentableTransformer())
    var bar: Bar = .firstBar

    @Persisted(key: "foo-baz", userDefaults: .standard)
    var baz: String?
}

let foo = Foo()

foo.bar // "Bar.firstBar"
foo.bar = .secondBar
UserDefaults.standard.object(forKey: "foo-bar") // 2

foo.baz // nil
foo.baz = "new-value"
UserDefaults.standard.object(forKey: "foo-baz") // "new-value"
```

`Persist` includes out of the box support for:

- `UserDefaults`
- `NSUbiquitousKeyValueStore`
- `FileManager`
- `InMemoryStorage` (a simple wrapper around a dictionary)

### Catching Errors

`Persister`'s `persist(_:)` and `retrieveValueOrThrow()` functions will throw if the storage or transformer throws an error.

`Persisted` wraps a `Persister` and exposes it as the `projectedValue`, which allows you to catch errors:

```swift
class Foo {
    @Persisted(key: "foo-bar", userDefaults: .standard)
    var bar: String?
}

do {
    let foo = Foo()
    try foo.$bar.persist("new-value")
    try foo.$bar.retrieveValueOrThrow()
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
let subscription = foo.$bar.updatesPublisher.sink { result in
    switch result {
    case .success(let update):
        print("New value:", update.newValue)

        switch update.event {
        case .persisted(let newValue):
            print("Value updated to:", newValue)
            // `update.newValue` will be new value
        case .removed:
            print("Value was deleted")
            // `update.newValue` will be default value
        }
    case .failure(let error):
        print("Error occurred retrieving value after update:", error)
    }
}
```

For versions prior to macOS 10.15, iOS 13, tvOS 13, or watchOS 6 a closure API is provided:

```swift
class Foo {
    @Persisted(key: "foo-bar", userDefaults: .standard)
    var bar: String?
}

let foo = Foo()
let subscription = foo.$bar.addUpdateListener() { result in
    switch result {
    case .success(let update):
        print("New value:", update.newValue)

        switch update.event {
        case .persisted(let newValue):
            print("Value updated to:", newValue)
            // `update.newValue` will be new value
        case .removed:
            print("Value was deleted")
            // `update.newValue` will be default value
        }
    case .failure(let error):
        print("Error occurred retrieving value after update:", error)
    }
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
let subscription = foo.$bar.addUpdateListener() { result in
    switch result {
    case .success(let update):
        // `update.newValue` is a `Bar?`
        print("New value:", update.newValue)

        switch update.event {
        case .persisted(let bar):
            // `bar` is the decoded `Bar`
            print("Value updated to:", bar)
        case .removed:
            print("Value was deleted")
        }
    case .failure(let error):
        print("Error occurred retrieving value after update:", error)
    }
}
```

Transformers are typesafe, e.g. `JSONTransformer` is only usable when the value to be stored is `Codable` and the `Storage` supports `Data`.

#### Chaining Transformers

If a value should go through multiple transformers you can chain them.

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
    @Persisted(key: "bar", userDefaults: .standard)
    var bar = "default"
}

var foo = Foo()
foo.bar // "default"
```

When provided as the `defaultValue` parameter the value is evaluated lazily when first required.

```swift
func makeUUID() -> UUID {
    print("Making UUID")
    return UUID()
}

struct Foo {
    @Persisted(key: "bar", userDefaults: .standard, defaultValue: makeUUID())
    var bar: UUID
}

/**
 This would not print anything because the default value is never required.
 */
var foo = Foo()
foo.bar = UUID()

/**
 This would print "Making UUID" once.
 */
var foo = Foo()
let firstCall = foo.bar
let secondCall = foo.bar
firstCall == secondCall // true
```

The default value can be optionally stored when used, either due to an error or because the storage returned `nil`. This can be useful when the first value is random and should be persisted between app launches once initially created.

```swift
struct Foo {
    @Persisted(key: "persistedWhenNilInt", userDefaults: .standard, defaultValue: Int.random(in: 1...10), defaultValuePersistBehaviour: .persistWhenNil)
    var persistedWhenNilInt: Int!

    @Persisted(key: "notPersistedWhenNilInt", userDefaults: .standard, defaultValue: Int.random(in: 1...10))
    var notPersistedWhenNilInt: Int!
}

var foo = Foo()

UserDefaults.standard.object(forKey: "persistedWhenNilInt") // nil
foo.persistedWhenNilInt // 3
UserDefaults.standard.object(forKey: "persistedWhenNilInt") // 3
foo.persistedWhenNilInt // 3

UserDefaults.standard.object(forKey: "notPersistedWhenNilInt") // nil
foo.notPersistedWhenNilInt // 7
UserDefaults.standard.object(forKey: "notPersistedWhenNilInt") // nil
foo.notPersistedWhenNilInt // 7

// ...restart app

UserDefaults.standard.object(forKey: "persistedWhenNilInt") // 3
foo.persistedWhenNilInt // 3

UserDefaults.standard.object(forKey: "notPersistedWhenNilInt") // nil
foo.notPersistedWhenNilInt // 4
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
        .package(url: "https://github.com/JosephDuffy/Persist.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "MyApp", dependencies: ["Persist"]),
    ],
    ...
)
```

# License

The project is released under the MIT license. View the [LICENSE](./LICENSE) file for the full license.
