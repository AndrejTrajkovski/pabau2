public struct ForgotPassSuccess: Equatable, Codable {
	public let success: Bool
	public let message: String?
	
	enum CodingKeys: String, CodingKey {
		case success
		case message
	}
}
