import Foundation

public struct Document: Codable, Identifiable {
	public let id: Int
	let title: String
	let format: String
	let date: Date
}
