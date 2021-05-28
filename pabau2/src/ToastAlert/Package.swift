// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ToastAlert",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ToastAlert",
            targets: ["ToastAlert"]),
    ],
    dependencies: [
        .package(name: "ToastUI",
                 url: "https://github.com/quanshousio/ToastUI.git",
                 from: Version.init(stringLiteral: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ToastAlert",
            dependencies: [
                "ToastUI"
            ]),
        .testTarget(
            name: "ToastAlertTests",
            dependencies: ["ToastAlert"]),
    ]
)
