// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppointmentDetails",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AppointmentDetails",
            targets: ["AppointmentDetails"])
    ],
    dependencies: [
        .package(url: "../CoreDataModel", from: Version.init(stringLiteral: "1.0.0")),
        .package(url: "../SharedComponents", from: Version.init("1.0.0")),
		.package(url: "../ChoosePathway", from: Version.init("1.0.0")),
		.package(url: "../PathwayList", from: Version.init("1.0.0"))
    ],
    targets: [
        .target(
            name: "AppointmentDetails",
            dependencies: ["CoreDataModel",
                           "SharedComponents",
						   "PathwayList",
						   "ChoosePathway"]),
        .testTarget(
            name: "AppointmentDetailsTests",
            dependencies: ["AppointmentDetails"])
    ]
)
