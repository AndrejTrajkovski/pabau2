// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChooseLocation",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ChooseLocation",
            targets: ["ChooseLocation"])
    ],
	dependencies: [
		.package(url: "../CoreDataModel",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../SharedComponents",
				 from: Version.init(stringLiteral: "1.0.0"))
	],
    targets: [
        .target(
            name: "ChooseLocation",
			dependencies: ["CoreDataModel",
						   "SharedComponents"]),
        .testTarget(
            name: "ChooseLocationTests",
            dependencies: ["ChooseLocation"])
    ]
)
