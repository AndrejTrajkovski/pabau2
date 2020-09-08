// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Calendar",
	platforms: [.iOS(.v13)],
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
		.package(name: "JZCalendarWeekView",
						 url: "https://github.com/zjfjack/JZCalendarWeekView.git",
						 from: Version.init(stringLiteral: "0.7.0"))
	],
	targets: [
		.target(
			name: "Calendar",
			dependencies: ["Form",
										 "FSCalendarSwiftUI",
										 "JZCalendarWeekView"
			]
		)
	]
)
