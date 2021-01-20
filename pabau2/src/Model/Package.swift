// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Model",
	platforms: [.iOS(.v14)],
	products: [
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
				 url: "https://github.com/malcommac/SwiftDate.git", from: "6.1.0"),
		.package(url: "../Util", from: Version.init(stringLiteral: "1.0.0"))
	],
	targets: [
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
						 package: "Tagged"),
				.product(name: "Util",
						 package: "Util")
			]
		),
		.testTarget(
			name: "ModelTests",
			dependencies: ["Model"]),
	]
)
