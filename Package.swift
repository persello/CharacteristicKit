// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CharacteristicKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "CharacteristicKit",
            targets: ["CharacteristicKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "CharacteristicKit",
            dependencies: ["Runtime"]
        )
    ]
)
