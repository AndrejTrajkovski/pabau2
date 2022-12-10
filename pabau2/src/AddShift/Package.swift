// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "AddShift",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "AddShift",
			targets: ["AddShift"])
	],
	dependencies: [
		.package(path: "../SharedComponents"),
		.package(path: "../Model"),
		.package(path: "../CoreDataModel"),
		.package(path: "../ChooseLocationAndEmployee")
	],
	targets: [
		.target(
			name: "AddShift",
			dependencies: [
				"SharedComponents",
				"Model",
				"CoreDataModel",
				"ChooseLocationAndEmployee"
			]),
		.testTarget(
			name: "AddShiftTests",
			dependencies: ["AddShift"])
	]
)
