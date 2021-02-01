// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Appointments",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Appointments",
            targets: ["Appointments"]),
    ],
    dependencies: [
		.package(url: "../Model", from: Version.init("1.0.0"))
    ],
    targets: [
        .target(
            name: "Appointments",
            dependencies: ["Model"]),
        .testTarget(
            name: "AppointmentsTests",
            dependencies: ["Appointments"]),
    ]
)
