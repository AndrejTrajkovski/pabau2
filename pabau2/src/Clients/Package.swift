// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Clients",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "Clients",
			targets: ["Clients"])
	],
	dependencies: [
		.package(path: "../Form"),
		.package(name: "SDWebImageSwiftUI",
						 url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
						 from: Version.init(stringLiteral: "2.0.0")),
        .package(name: "Facebook",
                         url: "https://github.com/facebook/facebook-ios-sdk.git",
                         .upToNextMajor(from: Version.init(stringLiteral: "9.3.0"))),
        .package(name: "ASCollectionView",
                 url: "https://github.com/apptekstudios/ASCollectionView.git",
                 from: Version.init(stringLiteral: "1.7.1"))
	],
	targets: [
		.target(
			name: "Clients",
			dependencies: [
				"Form",
                "ASCollectionView",
				"SDWebImageSwiftUI",
                .product(name: "FacebookShare", package: "Facebook")
		])
	]
)
