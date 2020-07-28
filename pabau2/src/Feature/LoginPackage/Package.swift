// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoginPackage",
		platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "LoginPackage",
            targets: ["LoginPackage"]),
    ],
    dependencies: [
	.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git",
					 from: Version.init(stringLiteral: "0.6.0")),
	.package(url: "../../UtilPackage",
					 from: Version.init(stringLiteral: "1.0.0")),
	.package(url: "../../ModelPackage",
					 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
					name: "LoginPackage",
					dependencies: [.product(name: "ComposableArchitecture",
																	package: "swift-composable-architecture"),
												 "UtilPackage",
												 "ModelPackage"
				]),
        .testTarget(
            name: "LoginPackageTests",
            dependencies: ["LoginPackage"]),
    ]
)
