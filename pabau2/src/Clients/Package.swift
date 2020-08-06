// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clients",
		platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Clients",
            targets: ["Clients"]),
    ],
    dependencies: [
			.package(url: "../Model",
							 from: Version.init(stringLiteral: "1.0.0")),
			.package(name: "Util",
							 url: "../Util",
							 from: Version.init(stringLiteral: "1.0.0"))
	],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Clients",
            dependencies: [
							"Model",
							"Util"
				])
    ]
)
