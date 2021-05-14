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
        .package(url: "../JourneyBase",
                 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../CoreDataModel",
				 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "ChoosePathway",
            dependencies: ["JourneyBase",
						   "CoreDataModel"]),
        .testTarget(
            name: "ChoosePathwayTests",
            dependencies: ["ChoosePathway"])
    ]
)
