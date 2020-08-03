import Foundation

public struct Alert: Codable, Identifiable {
	public let id: Int
	let title: String
	let date: Date
}
