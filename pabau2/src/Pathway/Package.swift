// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pathway",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Pathway",
            targets: ["Pathway"]),
    ],
    dependencies: [
		.package(url: "../Form",
						 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Pathway",
            dependencies: ["Form"]),
        .testTarget(
            name: "PathwayTests",
            dependencies: ["Pathway"]),
    ]
)
