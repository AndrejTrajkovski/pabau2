import Foundation

public struct Note: Identifiable, Codable, Equatable {
	public let id: Int
	let content: String
	let date: Date
}
