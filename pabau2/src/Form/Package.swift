// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Form",
		platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Form",
            targets: ["Form"]),
    ],
		dependencies: [
			.package(name: "Overture",
							 url: "https://github.com/pointfreeco/swift-overture.git",
							 from: Version.init(stringLiteral: "0.5.0")),
			.package(name: "ASCollectionView",
							 url: "https://github.com/apptekstudios/ASCollectionView.git",
							 from: Version.init(stringLiteral: "1.7.1")),
			.package(name: "BSImagePicker",
							 url: "https://github.com/mikaoj/BSImagePicker.git",
							 from: Version.init(stringLiteral: "3.2.1")),
			.package(url: "../Util",
							 from: Version.init(stringLiteral: "1.0.0")),
			.package(url: "../Model",
							 from: Version.init(stringLiteral: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
			.target(
				name: "Form",
				dependencies: [
					"Overture",
					"Util",
					"Model",
					"ASCollectionView",
					"BSImagePicker"
			]),
			.testTarget(
				name: "FormTests",
				dependencies: ["Form"]),
	]
)
