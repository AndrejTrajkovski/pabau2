import Tagged

public struct Employee: Decodable, Identifiable, Equatable, Hashable {
	public typealias Id = Tagged<Employee, String>
		
	public let id: Employee.Id
	
	public let name: String
	
	public let email: String
	
	public let avatar: String?
	
	public let locations: [Location.Id]
	
	public let passcode: String
	
	enum CodingKeys: String, CodingKey {
		case id
		case name = "full_name"
		case email, avatar
		case passcode
		case locations
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		self.id = try container.decode(Self.Id, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.email = try container.decode(String.self, forKey: .email)
		self.avatar = try container.decode(String?.self, forKey: .avatar)
		self.locations = try container.decode(String.self, forKey: .avatar).split(separator: ",").map { Location.Id.init(rawValue: .left(String($0))) }
		self.passcode = try container.decode(String.self, forKey: .passcode)
	}
}
