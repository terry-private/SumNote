// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BigIntExtensions",
    platforms: [
        .iOS("17.1")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BigIntExtensions",
            targets: ["BigIntExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt", from: "1.17.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BigIntExtensions",
            dependencies: [.product(name: "BigInt", package: "BigInt")]
        ),
        .testTarget(
            name: "BigIntExtensionsTests",
            dependencies: ["BigIntExtensions"]
        ),
    ]
)
