// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CharacteristicKit",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .watchOS(.v7),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "CharacteristicKit",
            targets: ["CharacteristicKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/wickwirew/Runtime.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "CharacteristicKit",
            dependencies: ["Runtime"]),
    ]
)
