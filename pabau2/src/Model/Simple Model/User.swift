public struct User: Codable, Identifiable, Equatable {
	
	public init(_ id: Int = 0, _ firstName: String = "") {
		self.id = id
		self.firstName = firstName
		self.avatarUrl = nil
		self.company = nil
		self.lastName = nil
	}
	
	public let id: Int?
	
	public let avatarUrl: String?
	
	public let firstName: String?
	
	public let lastName: String?
	
	public let company: Company?
	public init(id: Int? = nil, avatarUrl: String? = nil, firstName: String? = nil, lastName: String? = nil, company: Company? = nil) {
		self.id = id
		self.avatarUrl = avatarUrl
		self.firstName = firstName
		self.lastName = lastName
		self.company = company
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case avatarUrl = "avatar_url"
		case firstName
		case lastName
		case company
	}
	
}
