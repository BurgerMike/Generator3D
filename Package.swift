// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Generator3D",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Generator3D",
            targets: ["Generator3D"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Generator3D"
        ),
        .testTarget(
            name: "Generator3DTests",
            dependencies: ["Generator3D"]
        ),
    ]
)
