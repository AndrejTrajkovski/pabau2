// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EPaper",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EPaper",
            targets: ["EPaper"])
    ],
    dependencies: [
        .package(path: "../Form"),
        .package(path: "../Model"),
        .package(name: "SDWebImageSwiftUI",
                 url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
                 from: Version.init(stringLiteral: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EPaper",
            dependencies: ["Model",
                           "Form",
                           "SDWebImageSwiftUI"
            ]),
        .testTarget(
            name: "EPaperTests",
            dependencies: ["EPaper"])
    ]
)
