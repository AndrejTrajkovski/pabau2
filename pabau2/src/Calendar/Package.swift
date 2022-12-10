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
		.package(path: "../Form"),
		.package(path: "../FSCalendarSwiftUI"),
		.package(url: "https://github.com/AndrejTrajkovski/JZCalendarWeekView.git",
				 .revision("d1984a19f1f66ac8c73c763772ed3f14ab5857f9")),
		.package(path: "../AddAppointment"),
		.package(path: "../SharedComponents"),
		.package(path: "../AddBookout"),
		.package(path: "../AddShift"),
		.package(path: "../Filters"),
		.package(path: "../Appointments"),
		.package(path: "../CalendarList"),
        .package(path: "../AppointmentDetails")
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
						   "Appointments",
                           "CalendarList",
                           "AppointmentDetails"
			]
		)
	]
)
