// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FSCalendarSwiftUI",
		platforms: [.iOS("13.0")],
    products: [
        .library(
            name: "FSCalendarSwiftUI",
            targets: ["FSCalendarSwiftUI"]),
    ],
		dependencies: [
			.package(name: "FSCalendar",
							 url: "FSCalendar",
							 from: "1.0.0")
    ],
    targets: [
        .target(
            name: "FSCalendarSwiftUI",
            dependencies: ["FSCalendar"])
    ]
)
