import Foundation

public struct Communication: Codable, Identifiable {
	public let id: Int
	let title: String
	let subtitle: String
	let employee: Employee
	let date: Date
}
