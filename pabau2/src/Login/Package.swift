// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Login",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "Login",
			targets: ["Login"])
	],
	dependencies: [
		.package(url: "../Util",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Model",
				 from: Version.init(stringLiteral: "1.0.0"))
	],
	targets: [
		.target(
			name: "Login",
			dependencies: [
				"Util",
				"Model"
			]),
		.testTarget(
			name: "LoginTests",
			dependencies: ["Login"])
	]
)
