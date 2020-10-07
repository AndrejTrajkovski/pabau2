// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Calendar",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "Calendar",
			targets: ["Calendar"])
	],
	dependencies: [
		.package(url: "../Form",
						 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../FSCalendarSwiftUI",
						 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "https://github.com/AndrejTrajkovski/JZCalendarWeekView.git",
				 .branch("ATSectionsView"))
	],
	targets: [
		.target(
			name: "Calendar",
			dependencies: ["Form",
						   "FSCalendarSwiftUI",
						   .product(name: "JZCalendarWeekView", package: "JZCalendarWeekView")
			]
		)
	]
)
