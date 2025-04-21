// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "mtg-cli",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "mtg-cli", targets: ["mtg-cli"]),
        .executable(name: "scryfall-local", targets: ["scryfall-local"]),
        .library(name: "mtg-lib", targets: ["mtg"]),
        .library(name: "scryfall-lib", targets: ["scryfall"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/swiftcsv/SwiftCSV", from: "0.8.0"),
        .package(name: "swift-armcknight", path: "swift-armcknight"),
        .package(name: "Progress", path: "Progress.swift"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "mtg-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftCSV", package: "SwiftCSV"),
                .product(name: "Progress", package: "Progress"),
                .product(name: "Logging", package: "swift-log"),
                "mtg",
            ],
            path: "mtg-cli"
        ),
        .executableTarget(
            name: "scryfall-local",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Progress", package: "Progress"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Swifter", package: "Swifter"),
                "mtg",
                "scryfall",
            ],
            path: "scryfall-local"
        ),
        .target(
            name: "mtg",
            dependencies: [
                "scryfall",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftCSV", package: "SwiftCSV"),
                .product(name: "SwiftArmcknight", package: "swift-armcknight")
            ],
            path: "mtg"
        ),
        .target(
            name: "scryfall",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "scryfall"
        ),
        .testTarget(
            name: "mtg-tests",
            dependencies: ["mtg"],
            path: "mtg-tests"
        ),
    ]
)
