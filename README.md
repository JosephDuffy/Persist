# Persist

Property wrapper for storage and retrieval of values with support for transformations such as storing as JSON.

## Usage

Persist provides the `Persisted` property wrapper, which handles the persistence and retrieval of values by utilising the `Persister`. When creating a `Persisted` property wrapper any form of storage may be used. Included with `Persist` is an extension to `UserDefaults` to support persistence.

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

### Transformers

Some storage methods will only support a subset of types, or you might want to modify how some values are encoded/decoded (e.g. to ensure on-disk date representation are the same as what an API sends/expects). This is where transformers come in:

```swift
struct Bar: Codable {
    var baz: String
}

class Foo {
    @Persisted(key: "bar", storedBy: UserDefaults.standard, transformer: JSONTransformer())
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

Transformers are typesafe, e.g. `JSONTransformer` is only usable when the value to be stored is `Codable`.

### Property Wrapper Initialisation

To support dependency injection or to initialise more complex `Persisted` instances you may initialise the property wrapper in your own init functions:

```swift
class Foo {
    @Persisted
    var bar: String?

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let transformer = JSONTransformer(encoder: encoder, decoder: decoder)
        _bar = Persisted(key: "foo-bar", storage: UserDefaults.standard, transformer: transformer)
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