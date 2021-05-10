// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataModel",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CoreDataModel",
            targets: ["CoreDataModel"])
    ],
    dependencies: [
        .package(url: "../Model",
                 from: Version.init(stringLiteral: "0.16.0")),
        .package(name: "CoreStore",
                 url: "https://github.com/JohnEstropia/CoreStore", from: "8.0.1")
    ],
    targets: [
        .target(
            name: "CoreDataModel",
            dependencies: [
                "Model",
                "CoreStore"
            ]
        ),
        .testTarget(
            name: "CoreDataModelTests",
            dependencies: ["CoreDataModel"]),
    ]
)
