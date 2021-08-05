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
		.package(url: "../Filters",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../AddAppointment",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Appointments",
				 from: Version.init(stringLiteral: "1.0.0")),
        .package(url: "../ChoosePathway",
                 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../SharedComponents",
				 from: Version.init(stringLiteral: "1.0.0")),
        .package(url: "../TextLog",
                 from: Version("1.0.0"))
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
