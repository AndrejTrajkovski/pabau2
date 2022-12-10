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
		.package(path: "../Util"),
		.package(path: "../Model")
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
