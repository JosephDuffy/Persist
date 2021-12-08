// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Persist",
    platforms: [
        .iOS(.v13), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Persist", targets: ["Persist"]),
    ],
    targets: [
        .target(name: "Persist"),
        .testTarget(name: "PersistTests", dependencies: ["Persist"]),
    ]
)
