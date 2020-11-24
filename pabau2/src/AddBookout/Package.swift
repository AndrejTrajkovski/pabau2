// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AddBookout",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AddBookout",
            targets: ["AddBookout"]),
    ],
    dependencies: [
		.package(url: "../Form",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../SharedComponents",
						 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "AddBookout",
            dependencies: [
				"Form",
				"SharedComponents"
			]),
        .testTarget(
            name: "AddBookoutTests",
            dependencies: ["AddBookout"]),
    ]
)
