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
<<<<<<< HEAD
							 from: "1.0.0"),
			.package(name: "swift-composable-architecture",
							 url: "https://github.com/pointfreeco/swift-composable-architecture.git",
							 from: Version.init(stringLiteral: "0.6.0")),
			.package(name: "SwiftDate",
							 url: "https://github.com/malcommac/SwiftDate.git", from: "6.1.0")
    ],
    targets: [
		.target(
			name: "FSCalendarSwiftUI",
			dependencies: [
				"FSCalendar",
				.product(name: "ComposableArchitecture",
						 package: "swift-composable-architecture"),
				.product(name: "SwiftDate",
						 package: "SwiftDate"),
			])
=======
							 from: "1.0.0")
    ],
    targets: [
        .target(
            name: "FSCalendarSwiftUI",
            dependencies: [
							"FSCalendar"
			]
		)
>>>>>>> calendarWeekView
    ]
)
