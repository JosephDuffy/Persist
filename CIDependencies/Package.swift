// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "CIDependencies",
    platforms: [
        .macOS(.v10_10),
    ],
    dependencies: [
        .package(url: "https://github.com/JosephDuffy/xcutils.git", from: "0.1.0"),
        .package(url: "https://github.com/eneko/SourceDocs.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "CIDependencies")
    ]
)
