// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Filters",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Filters",
            targets: ["Filters"]),
    ],
    dependencies: [
		.package(url: "../Util",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(name: "swift-composable-architecture",
				 url: "https://github.com/pointfreeco/swift-composable-architecture.git",
				 from: Version.init(stringLiteral: "0.6.0"))
    ],
    targets: [
        .target(
            name: "Filters",
            dependencies: [
				"Util",
				.product(name: "ComposableArchitecture",
						 package: "swift-composable-architecture")
			]),
        .testTarget(
            name: "FiltersTests",
            dependencies: ["Filters"]),
    ]
)
