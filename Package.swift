// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Readers",
    products: [
        .library(
            name: "Readers",
            targets: ["Readers"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Position.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/FileTypes.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Readers",
            dependencies: [
                .product(name: "Position", package: "Position"),
                .product(name: "FileTypes", package: "FileTypes"),
            ],
        ),
    ]
)
