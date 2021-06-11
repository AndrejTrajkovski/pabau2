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
		.package(url: "../ChooseEmployees",
				 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../ChooseLocation",
				 from: Version.init(stringLiteral: "1.0.0"))
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
