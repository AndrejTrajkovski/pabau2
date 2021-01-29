import Tagged

public struct User: Codable, Equatable {
	public typealias ID = Tagged<User, String>
	
	public let userID: ID
	public let companyID, fullName, avatar: String
	public let logo: String
	public let expired: Bool
	public let companyName: String
	public let apiKey: String

	enum CodingKeys: String, CodingKey {
		case userID = "user_id"
		case companyID = "company_id"
		case fullName = "full_name"
		case avatar, logo, expired
		case companyName = "company_name"
		case apiKey = "api_key"
	}
}
