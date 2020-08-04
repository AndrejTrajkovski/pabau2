import Foundation

public struct Alert: Codable, Identifiable, Equatable {
	public let id: Int
	let title: String
	let date: Date
}
