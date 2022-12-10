// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedComponents",
	platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SharedComponents",
            targets: ["SharedComponents"])
    ],
    dependencies: [
		.package(path: "../Util"),
		.package(path: "../Model"),
		.package(path: "../Avatar"),
		.package(name: "SDWebImageSwiftUI",
				 url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
				 from: Version.init(stringLiteral: "2.0.0")),
		.package(path: "../ToastAlert")

    ],
    targets: [
        .target(
            name: "SharedComponents",
            dependencies: [
				"Util",
				"Model",
				"Avatar",
				"SDWebImageSwiftUI",
				"ToastAlert"
			]),
        .testTarget(
            name: "SharedComponentsTests",
            dependencies: ["SharedComponents"])
    ]
)
