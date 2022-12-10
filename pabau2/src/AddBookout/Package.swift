// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AddBookout",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AddBookout",
            targets: ["AddBookout"])
    ],
    dependencies: [
		.package(path: "../Form"),
		.package(path: "../SharedComponents"),
		.package(path: "../CoreDataModel"),
		.package(path: "../ChooseLocationAndEmployee")
    ],
    targets: [
        .target(
            name: "AddBookout",
            dependencies: [
				"Form",
				"SharedComponents",
				"CoreDataModel",
				"ChooseLocationAndEmployee"
			]),
        .testTarget(
            name: "AddBookoutTests",
            dependencies: ["AddBookout"])
    ]
)
