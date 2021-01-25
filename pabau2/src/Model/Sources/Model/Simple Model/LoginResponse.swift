import Foundation

public struct LoginResponse: Codable, Equatable {
	let success: Bool
	let total: Int
	let url: String
	public let users: [User]

	enum CodingKeys: String, CodingKey {
		case success, total
		case url = "URL"
		case users = "appointments"
	}
}
