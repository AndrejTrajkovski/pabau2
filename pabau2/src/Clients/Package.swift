// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Clients",
	platforms: [.iOS(.v13)],
	products: [
		.library(
			name: "Clients",
			targets: ["Clients"]),
	],
	dependencies: [
		.package(name: "Form",
						 url: "../Form",
						 from: Version.init(stringLiteral: "1.0.0")),
		.package(name: "SDWebImageSwiftUI",
						 url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
						 from: Version.init(stringLiteral: "1.0.0"))
	],
	targets: [
		.target(
			name: "Clients",
			dependencies: [
				"Form",
				"SDWebImageSwiftUI"
		])
	]
)
