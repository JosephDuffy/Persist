// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Persist",
    platforms: [
        .iOS(.v8), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Persist", targets: ["Persist"]),
        .library(name: "PersistUserDefaults", targets: ["PersistUserDefaults"]),
        .library(name: "PersistCore", targets: ["PersistCore"]),
    ],
    targets: [
        .target(name: "Persist", dependencies: ["PersistUserDefaults", "PersistCore"]),
        .testTarget(name: "PersistTests", dependencies: ["Persist", "TestHelpers"]),

        .target(name: "PersistUserDefaults", dependencies: ["PersistCore"]),
        .testTarget(name: "PersistUserDefaultsTests", dependencies: ["PersistUserDefaults", "TestHelpers"]),

        .target(name: "PersistCore"),
        .testTarget(name: "PersistCoreTests", dependencies: ["PersistCore", "TestHelpers"]),

        .target(name: "TestHelpers", dependencies: ["PersistCore"]),
    ]
)
