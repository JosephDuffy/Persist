// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Persist",
    platforms: [
        .iOS(.v8), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Persist", targets: ["Persist"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JosephDuffy/xcutils.git", .branch("master")),
    ],
    targets: [
        .target(name: "Persist"),
        .testTarget(name: "PersistTests", dependencies: ["Persist"]),
    ]
)
