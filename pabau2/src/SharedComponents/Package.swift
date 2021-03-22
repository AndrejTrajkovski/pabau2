// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedComponents",
	platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SharedComponents",
            targets: ["SharedComponents"])
    ],
    dependencies: [
		.package(url: "../Util",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Model",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Avatar",
				 from: Version.init(stringLiteral: "1.0.0"))

    ],
    targets: [
        .target(
            name: "SharedComponents",
            dependencies: [
				"Util",
				"Model",
				"Avatar"
			]),
        .testTarget(
            name: "SharedComponentsTests",
            dependencies: ["SharedComponents"])
    ]
)
