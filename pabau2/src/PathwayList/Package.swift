// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PathwayList",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "PathwayList",
            targets: ["PathwayList"])
    ],
    dependencies: [
		.package(url: "../Model", from: Version("1.0.0")),
		.package(url: "../SharedComponents", from: Version("1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PathwayList",
            dependencies: ["Model",
						   "SharedComponents"]),
        .testTarget(
            name: "PathwayListTests",
            dependencies: ["PathwayList"])
    ]
)
