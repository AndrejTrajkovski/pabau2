// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Model",
		platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Model",
            targets: ["Model"]),
    ],
    dependencies: [
			.package(name: "swift-composable-architecture",
							 url: "https://github.com/pointfreeco/swift-composable-architecture.git",
			from: Version.init(stringLiteral: "0.6.0")),
			.package(name: "Tagged",
							 url: "https://github.com/pointfreeco/swift-tagged.git",
			from: Version.init(stringLiteral: "0.5.0")),
			.package(name: "NonEmpty",
							 url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.2.2"),
			.package(name: "SwiftDate",
							 url: "https://github.com/malcommac/SwiftDate.git", from: "6.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Model",
						dependencies: [
							.product(name: "ComposableArchitecture",
											 package: "swift-composable-architecture"),
							.product(name: "SwiftDate",
											 package: "SwiftDate"),
							.product(name: "NonEmpty",
											 package: "NonEmpty"),
							.product(name: "Tagged",
											 package: "Tagged")
					]
			),
        .testTarget(
            name: "ModelTests",
            dependencies: ["Model"]),
    ]
)
