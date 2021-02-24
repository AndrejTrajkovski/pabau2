// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Util",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Util",
            targets: ["Util"])
    ],
    dependencies: [
		.package(name: "SwiftDate",
						 url: "https://github.com/malcommac/SwiftDate.git", from: "6.1.0")
    ],
    targets: [
        .target(
            name: "Util",
            dependencies: [
				.product(name: "SwiftDate",
						 package: "SwiftDate")
			])
    ]
)
