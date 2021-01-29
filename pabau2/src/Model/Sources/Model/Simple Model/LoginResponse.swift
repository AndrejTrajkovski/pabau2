import Foundation

public struct LoginResponse: Codable, Equatable, ResponseStatus {
	public let success: Bool
	public let message: String?
	let url: String
	public let users: [User]

	enum CodingKeys: String, CodingKey {
		case success, message
		case url = "URL"
		case users = "appointments"
	}
}
