import Tagged

public struct User: Codable, Equatable {
	public typealias ID = Tagged<User, String>
	
	public let userID: ID
	public let companyID, fullName, avatar: String
	public let logo: String
	public let expired: Bool
	public let headerTheme: String
	public let backgroundImage: String
	public let videoURL, buttonCol: String
	public let podURL: String
	public let companyName, companyCity: String
	public let company2Fa, authorizedDevices, googleAuth: Int
	public let apiKey: String

	enum CodingKeys: String, CodingKey {
		case userID = "user_id"
		case companyID = "company_id"
		case fullName = "full_name"
		case avatar, logo, expired
		case headerTheme = "header_theme"
		case backgroundImage = "background_image"
		case videoURL = "video_url"
		case buttonCol = "button_col"
		case podURL = "pod_url"
		case companyName = "company_name"
		case companyCity = "company_city"
		case company2Fa = "company_2fa"
		case authorizedDevices = "authorized_devices"
		case googleAuth = "google_auth"
		case apiKey = "api_key"
	}
}
