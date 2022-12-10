// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CalendarList",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CalendarList",
            targets: ["CalendarList"])
    ],
    dependencies: [
		.package(path: "../Appointments"),
		.package(path: "../Model"),
		.package(path: "../SharedComponents")
    ],
    targets: [
        .target(
            name: "CalendarList",
            dependencies: [
				"Appointments",
				"Model",
				"SharedComponents"
			]),
        .testTarget(
            name: "CalendarListTests",
            dependencies: ["CalendarList"])
    ]
)
