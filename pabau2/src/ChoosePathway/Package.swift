// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChoosePathway",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ChoosePathway",
            targets: ["ChoosePathway"])
    ],
    dependencies: [
        .package(path: "../SharedComponents"),
		.package(path: "../CoreDataModel")
    ],
    targets: [
        .target(
            name: "ChoosePathway",
            dependencies: ["SharedComponents",
						   "CoreDataModel"]),
        .testTarget(
            name: "ChoosePathwayTests",
            dependencies: ["ChoosePathway"])
    ]
)
