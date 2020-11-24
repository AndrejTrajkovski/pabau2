// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AddShift",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AddShift",
            targets: ["AddShift"]),
    ],
    dependencies: [
		.package(url: "../ListPicker",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../SharedComponents",
						 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Model",
				 from: Version.init(stringLiteral: "1.0.0")),
    ],
    targets: [
        .target(
            name: "AddShift",
            dependencies: ["ListPicker", "SharedComponents", "Model"]),
        .testTarget(
            name: "AddShiftTests",
            dependencies: ["AddShift"]),
    ]
)
