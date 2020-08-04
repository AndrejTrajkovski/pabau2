import Foundation

public struct Document: Codable, Identifiable, Equatable {
	public let id: Int
	let title: String
	let format: String
	let date: Date
}
