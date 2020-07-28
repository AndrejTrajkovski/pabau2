// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "JourneyPackage",
	platforms: [.iOS(.v13)],
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "JourneyPackage",
			targets: ["JourneyPackage"]),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git",
						 from: Version.init(stringLiteral: "0.6.0")),
		.package(name: "Overture",
						 url: "https://github.com/pointfreeco/swift-overture.git",
						 from: Version.init(stringLiteral: "0.5.0")),
		.package(name: "ASCollectionView",
						 url: "https://github.com/apptekstudios/ASCollectionView.git",
						 from: Version.init(stringLiteral: "1.7.1")),
		.package(name: "BSImagePicker",
						 url: "https://github.com/mikaoj/BSImagePicker.git",
						 from: Version.init(stringLiteral: "3.2.1")),
		.package(url: "../../UtilPackage",
						 from: Version.init(stringLiteral: "1.0.0")),
		.package(url: "../../ModelPackage",
						 from: Version.init(stringLiteral: "1.0.0"))
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "JourneyPackage",
			dependencies: [.product(name: "ComposableArchitecture",
															package: "swift-composable-architecture"),
										 "Overture",
										 "UtilPackage",
										 "ModelPackage",
										 "ASCollectionView",
										 "BSImagePicker"
		]),
		.testTarget(
			name: "JourneyPackageTests",
			dependencies: ["JourneyPackage"]),
	]
)
