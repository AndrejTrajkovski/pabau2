// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AddAppointment",
	platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AddAppointment",
            targets: ["AddAppointment"])
    ],
    dependencies: [
		.package(url: "../Form",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../SharedComponents",
						 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        .target(
            name: "AddAppointment",
            dependencies: [
				"Form",
				"SharedComponents"
			]),
        .testTarget(
            name: "AddAppointmentTests",
            dependencies: ["AddAppointment"])
    ]
)
