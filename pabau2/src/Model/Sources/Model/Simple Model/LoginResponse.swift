import Foundation

struct LoginResponse: Codable {
	let success: Bool
	let total: Int
	let url: String
	let users: [User]

	enum CodingKeys: String, CodingKey {
		case success, total
		case url = "URL"
		case users = "appointments"
	}
}
