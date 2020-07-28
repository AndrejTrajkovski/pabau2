// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Form",
		platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Form",
            targets: ["Form"]),
    ],
    dependencies: [
			.package(path: "https://github.com/pointfreeco/swift-composable-architecture.git")
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Form",
            dependencies: []),
        .testTarget(
            name: "FormTests",
            dependencies: ["Form"]),
    ],
		swiftLanguageVersions: [
			.version("13.0")
		]
)
