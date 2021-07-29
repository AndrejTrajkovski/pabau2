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
		.package(url: "../Appointments",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../Model",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../SharedComponents",
				 from: Version.init(stringLiteral: "1.0.0"))
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
