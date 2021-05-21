// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Filters",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Filters",
            targets: ["Filters"])
    ],
    dependencies: [
		.package(url: "../Util",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Model",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../CoreDataModel",
				 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Filters",
            dependencies: [
				"Util",
				"Model",
				"CoreDataModel"
			]),
        .testTarget(
            name: "FiltersTests",
            dependencies: ["Filters"])
    ]
)
