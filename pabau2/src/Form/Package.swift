// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Form",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "Form",
			targets: ["Form"])
	],
	dependencies: [
		.package(name: "Overture",
				 url: "https://github.com/pointfreeco/swift-overture.git",
				 from: Version.init(stringLiteral: "0.5.0")),
		.package(name: "BSImagePicker",
				 url: "https://github.com/mikaoj/BSImagePicker.git",
				 from: Version.init(stringLiteral: "3.2.1")),
		.package(path: "../Util"),
		.package(path: "../Model"),
		.package(path: "../SharedComponents"),
		.package(name: "SDWebImageSwiftUI",
				 url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
				 from: Version.init(stringLiteral: "2.0.0")),
		.package(path: "../CoreDataModel")
	],
	targets: [
		.target(
			name: "Form",
			dependencies: [
				"Overture",
				"Util",
				"Model",
				"BSImagePicker",
				"SharedComponents",
				"SDWebImageSwiftUI",
				"CoreDataModel"
			]),
		.testTarget(
			name: "FormTests",
			dependencies: ["Form"])
	]
)
