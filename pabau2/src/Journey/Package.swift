// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
	name: "Journey",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "Journey",
			targets: ["Journey"])
	],
	dependencies: [
		.package(path: "../Form"),
		.package(path: "../FSCalendarSwiftUI"),
		.package(path: "../Filters"),
		.package(path: "../AddAppointment"),
		.package(path: "../Appointments"),
        .package(path: "../ChoosePathway"),
		.package(path: "../SharedComponents"),
        .package(path: "../TextLog")
	],
	targets: [
		.target(
			name: "Journey",
			dependencies: ["Form",
						   "FSCalendarSwiftUI",
						   "Filters",
						   "AddAppointment",
						   "Appointments",
                           "ChoosePathway",
						   "SharedComponents",
                           "TextLog"
			]
		)
	]
)
