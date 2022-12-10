// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChooseLocationAndEmployee",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ChooseLocationAndEmployee",
            targets: ["ChooseLocationAndEmployee"])
    ],
    dependencies: [
		.package(path: "../ChooseEmployees"),
		.package(path: "../ChooseLocation")
    ],
    targets: [
        .target(
            name: "ChooseLocationAndEmployee",
            dependencies: ["ChooseEmployees",
						   "ChooseLocation"]),
        .testTarget(
            name: "ChooseLocationAndEmployeeTests",
            dependencies: ["ChooseLocationAndEmployee"])
    ]
)
