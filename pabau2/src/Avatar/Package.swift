// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Avatar",
	platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Avatar",
            targets: ["Avatar"])
    ],
    dependencies: [
		.package(name: "SDWebImageSwiftUI",
						 url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
						 from: Version.init(stringLiteral: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Avatar",
            dependencies: [
				"SDWebImageSwiftUI"
			]),
        .testTarget(
            name: "AvatarTests",
            dependencies: ["Avatar"])
    ]
)
