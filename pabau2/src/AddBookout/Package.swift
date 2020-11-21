// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AddBookout",
	platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AddBookout",
            targets: ["AddBookout"]),
    ],
    dependencies: [
		.package(url: "../Form",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../ListPicker",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../AddEventControls",
						 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "AddBookout",
            dependencies: [
				"Form",
				"ListPicker",
				"AddEventControls"
			]),
        .testTarget(
            name: "AddBookoutTests",
            dependencies: ["AddBookout"]),
    ]
)
