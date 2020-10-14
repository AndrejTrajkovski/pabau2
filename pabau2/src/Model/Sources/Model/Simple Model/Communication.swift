import Foundation

public struct Communication: Codable, Identifiable, Equatable {
	public let id: Int
	public let title: String
	public let subtitle: String
	public let employee: Employee
	public let initials: String
	public let date: Date
	public let channel: CommunicationChannel
}

public enum CommunicationChannel: String, Codable, Equatable {
	case sms
	case email
}

extension Communication {
	static let mockComm =
	[
		Communication(id: 1,
									title: "Dear doctor",
									subtitle: """
			versions have evolved over the years, sometimes by accident, sometimes on
			purpose (injected humour and the like).
			""",
									employee: Employee.init(id: 1, name: "", locationId: Location.randomId()),
									initials: "DD",
									date: Date(),
									channel: .sms)
		,
		Communication(id: 1,
		title: "Hello Houston",
		subtitle: "desktop publishing packages and web page editors",
		employee: Employee.init(id: 1, name: "", locationId: Location.randomId()),
		initials: "OP",
		date: Date(),
		channel: .sms)
		,
		Communication(id: 1,
		title: "Test communication",
		subtitle: "as opposed to using, making it look like readable English. Many",
		employee: Employee.init(id: 1, name: "", locationId: Location.randomId()),
		initials: "FA",
		date: Date(),
		channel: .sms)
		,
		Communication(id: 1,
		title: "Comm title",
		subtitle: "Lorem Ipsum is that it has a more-or-less normal distribution of letters",
		employee: Employee.init(id: 1, name: "", locationId: Location.randomId()),
		initials: "BB",
		date: Date(),
		channel: .sms)
		,
		Communication(id: 3,
		title: "Comm title 2",
		subtitle: "readable content of a page when looking at its layout. The point of using",
		employee: Employee.init(id: 1, name: "", locationId: Location.randomId()),
		initials: "AT",
		date: Date(),
		channel: .email)
	]
}
