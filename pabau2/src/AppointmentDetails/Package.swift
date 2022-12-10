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
        .package(path: "../CoreDataModel"),
        .package(path: "../SharedComponents"),
		.package(path: "../ChoosePathway"),
		.package(path: "../PathwayList")
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
