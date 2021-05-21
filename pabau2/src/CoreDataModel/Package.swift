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
        .package(name: "swift-composable-architecture",
                 url: "https://github.com/pointfreeco/swift-composable-architecture.git",
                 from: Version.init(stringLiteral: "0.16.0")),
        .package(name: "Tagged",
                 url: "https://github.com/pointfreeco/swift-tagged.git",
                 from: Version.init(stringLiteral: "0.5.0")),
        .package(name: "CoreStore",
                 url: "https://github.com/JohnEstropia/CoreStore", from: "8.0.1"),
		.package(url: "../Model",
				 from: Version.init(stringLiteral: "1.0.0")),
        .package(url: "../Util", from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "CoreDataModel",
            dependencies: [
                "CoreStore",
				"Model"
            ]
        ),
        .testTarget(
            name: "CoreDataModelTests",
            dependencies: ["CoreDataModel"])
    ]
)
