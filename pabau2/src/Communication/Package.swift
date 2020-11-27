// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Communication",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Communication",
            targets: ["Communication"])
    ],
    dependencies: [
        .package(url: "../Model",
                         from: Version.init(stringLiteral: "1.0.0")),
        .package(url: "../Util",
                         from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Communication",
            dependencies: [
                "Model",
                "Util"
        ])
    ]
)
