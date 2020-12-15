// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Util",
    platforms: [.iOS(.v14)],
    products: [
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
