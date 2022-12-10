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
		.package(path: "../Util"),
		.package(path: "../Model"),
		.package(path: "../CoreDataModel")
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
