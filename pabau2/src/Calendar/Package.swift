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
				 .branch("shifts")),
		.package(url: "../AddAppointment",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../SharedComponents",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../AddBookout",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../AddShift",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Filters",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Appointments",
				 from: Version.init(stringLiteral: "1.0.0"))
	],
	targets: [
		.target(
			name: "Calendar",
			dependencies: ["Form",
						   "FSCalendarSwiftUI",
						   .product(name: "JZCalendarWeekView", package: "JZCalendarWeekView"),
						   "AddAppointment",
						   "SharedComponents",
						   "AddBookout",
						   "AddShift",
						   "Filters",
						   "Appointments"
			]
		)
	]
)
