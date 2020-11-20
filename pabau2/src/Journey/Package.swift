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
		.package(url: "../Form",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../FSCalendarSwiftUI",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../EmployeesFilter",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../ListPicker",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../AddAppointment",
				 from: Version.init(stringLiteral: "1.0.0")),
	],
	targets: [
		.target(
			name: "Journey",
			dependencies: ["Form",
						   "FSCalendarSwiftUI",
						   "EmployeesFilter",
						   "ListPicker",
						   "AddAppointment"
			]
		)
	]
)
