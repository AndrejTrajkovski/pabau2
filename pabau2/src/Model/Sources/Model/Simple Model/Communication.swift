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
