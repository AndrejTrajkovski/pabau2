// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "Model",
	platforms: [.iOS(.v14)],
	products: [
		.library(
			name: "Model",
			targets: ["Model"]),
	],
	dependencies: [
        .package(name: "swift-composable-architecture",
                 url: "https://github.com/pointfreeco/swift-composable-architecture.git",
                 from: Version.init(stringLiteral: "0.19.0")),
        .package(name: "swift-tagged",
                 url: "https://github.com/pointfreeco/swift-tagged.git",
                 from: Version.init(stringLiteral: "0.5.0")),
		.package(url: "../Util", from: Version.init(stringLiteral: "1.0.0")),
		.package(name: "Overture",
				 url: "https://github.com/pointfreeco/swift-overture.git",
				 from: Version.init(stringLiteral: "0.5.0"))
	],
	targets: [
		.target(
			name: "Model",
			dependencies: [
                .product(name: "ComposableArchitecture",
                         package: "swift-composable-architecture"),
                .product(name: "Tagged",
                         package: "swift-tagged"),
                .product(name: "Util",
                         package: "Util"),
                .product(name: "Overture",
                         package: "Overture"),
                .product(name: "Overture",
                         package: "Overture")
            ]
		),
		.testTarget(
			name: "ModelTests",
			dependencies: ["Model"],
			resources: [
					// Copy Tests/ExampleTests/Resources directories as-is.
					// Use to retain directory structure.
					// Will be at top level in bundle.
					.copy("Resources"),
				  ]
		)
	]
)
