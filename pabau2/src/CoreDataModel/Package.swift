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
        .package(name: "NonEmpty",
                 url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.2.2"),
        .package(url: "../Util", from: Version.init(stringLiteral: "1.0.0")),
        .package(name: "Overture",
                 url: "https://github.com/pointfreeco/swift-overture.git",
                 from: Version.init(stringLiteral: "0.5.0")),
        .package(name: "CoreStore",
                 url: "https://github.com/JohnEstropia/CoreStore", from: "8.0.1")
    ],
    targets: [
        .target(
            name: "CoreDataModel",
            dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture"),
                .product(name: "NonEmpty",
                         package: "NonEmpty"),
                .product(name: "Tagged",
                         package: "Tagged"),
                .product(name: "Util",
                         package: "Util"),
                .product(name: "Overture",
                         package: "Overture"),
                .product(name: "CoreStore",
                         package: "CoreStore")
            ]
        ),
        .testTarget(
            name: "CoreDataModelTests",
            dependencies: ["CoreDataModel"]),
    ]
)
