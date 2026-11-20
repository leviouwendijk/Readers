// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ReadersTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Position.git", branch: "master"),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "ReadersTests",
            dependencies: [
                .product(name: "Readers", package: "Readers"),
                .product(name: "Position", package: "Position"),
            ]
        ),
    ]
)
