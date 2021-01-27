public struct ResetPassSuccess: Equatable, Codable, ResponseStatus {
	public let success: Bool
	public let message: String?
	
	enum CodingKeys: String, CodingKey {
		case success
		case message
	}
}
