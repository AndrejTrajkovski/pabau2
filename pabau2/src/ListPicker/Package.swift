// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "ListPicker",
	platforms: [.iOS(.v14)],
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "ListPicker",
			targets: ["ListPicker"]),
	],
	dependencies: [
		.package(url: "../Util",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(name: "swift-composable-architecture",
				 url: "https://github.com/pointfreeco/swift-composable-architecture.git",
				 from: Version.init(stringLiteral: "0.6.0")),
	],
	targets: [
		.target(
			name: "ListPicker",
			dependencies: [
				.product(name: "Util", package: "Util"),
				.product(name: "ComposableArchitecture",
						 package: "swift-composable-architecture")
			]),
		.testTarget(
			name: "ListPickerTests",
			dependencies: ["ListPicker"]),
	]
)
