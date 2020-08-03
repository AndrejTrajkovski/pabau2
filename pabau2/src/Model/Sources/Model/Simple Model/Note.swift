import Foundation

public struct Note: Identifiable, Codable {
	public let id: Int
	let content: String
	let date: Date
}
