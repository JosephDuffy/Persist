// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Persist",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6),
    ],
    products: [
        .library(name: "Persist", targets: ["Persist"]),
    ],
    targets: [
        .target(name: "Persist"),
        .testTarget(name: "PersistTests", dependencies: ["Persist"]),
    ]
)
