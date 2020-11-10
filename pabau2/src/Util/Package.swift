// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Util",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Util",
            targets: ["Util"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Util",
            dependencies: [])
    ]
)
