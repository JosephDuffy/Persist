// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Persist",
    platforms: [
        .iOS(.v12), .macOS(.v10_14), .tvOS(.v12), .watchOS(.v5),
    ],
    products: [
        .library(name: "Persist", targets: ["Persist"]),
    ],
    targets: [
        .target(name: "Persist"),
        .testTarget(name: "PersistTests", dependencies: ["Persist"]),
    ]
)
