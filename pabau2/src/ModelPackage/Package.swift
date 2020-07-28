// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModelPackage",
		platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ModelPackage",
            targets: ["ModelPackage"]),
    ],
    dependencies: [
			.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git",
			from: Version.init(stringLiteral: "0.6.0")),
			.package(name: "NonEmpty",
							 url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.2.2"),
			.package(name: "SwiftDate",
							 url: "https://github.com/malcommac/SwiftDate.git", from: "6.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ModelPackage",
						dependencies: [
							.product(name: "ComposableArchitecture",
											 package: "swift-composable-architecture"),
							.product(name: "SwiftDate",
											 package: "SwiftDate"),
							.product(name: "NonEmpty",
											 package: "NonEmpty")
						]
			),
        .testTarget(
            name: "ModelPackageTests",
            dependencies: ["ModelPackage"]),
    ]
)
