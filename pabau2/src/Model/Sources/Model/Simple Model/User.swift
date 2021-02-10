import Tagged

public struct User: Codable, Equatable {
	public typealias ID = Tagged<User, Int>
	
	public let userID: ID
	public let companyID, fullName, avatar: String
	public let logo: String
	public let companyName: String
    public let apiKey: String

	enum CodingKeys: String, CodingKey {
		case userID = "user_id"
		case companyID = "company_id"
		case fullName = "full_name"
		case avatar, logo
		case companyName = "company_name"
		case apiKey = "api_key"
	}
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let iId = try? container.decode(Int.self, forKey: .userID) {
            self.userID = Tagged(rawValue: iId)
        } else if let sId = try? container.decode(String.self, forKey: .userID), let id = Int(sId) {
            self.userID = Tagged(rawValue: id)
        } else {
            throw RequestError.jsonDecoding("User Id invalid")
        }

        if let sCompanyID = try? container.decode(String.self, forKey: .companyID) {
            self.companyID = sCompanyID
        } else if let iCompanyID = try? container.decode(Int.self, forKey: .companyID) {
            self.companyID = "\(iCompanyID)"
        } else {
            throw RequestError.jsonDecoding("Company Id invalid")
        }
        
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.avatar = try container.decode(String.self, forKey: .avatar)
        self.logo = try container.decode(String.self, forKey: .logo)
        self.companyName = try container.decode(String.self, forKey: .companyName)
        
        if let apiKey = try? container.decode(String.self, forKey: .apiKey) {
            self.apiKey = apiKey
        } else {
            self.apiKey = ""
        }
    }
    
    public init(userID: ID, companyID: String, fullName: String, avatar: String, logo: String, companyName: String, apiKey: String) {
        self.userID = userID
        self.companyID = companyID
        self.fullName = fullName
        self.avatar = avatar
        self.logo = logo
        self.companyName = companyName
        self.apiKey = apiKey
    }
}
