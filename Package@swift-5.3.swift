// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Persist",
    platforms: [
        .iOS(.v9), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Persist", targets: ["Persist"]),
        .library(name: "PersistLogger", targets: ["PersistLogger"]),
    ],
    targets: [
        .target(name: "Persist", dependencies: ["PersistLogger"]),
        .testTarget(name: "PersistTests", dependencies: ["Persist"]),
        .target(name: "PersistLogger"),
    ]
)
