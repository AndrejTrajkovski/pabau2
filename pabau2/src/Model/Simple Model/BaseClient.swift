import Foundation

public struct BaseClient: Codable, Identifiable, Equatable {
	public init(id: Int,
								firstName: String,
								lastName: String,
								dOB: String,
								email: String?,
								avatar: String?,
								phone: String?) {
		self.id = id
		self.firstName = firstName
		self.lastName = lastName
		self.dOB = dOB
		self.email = email
		self.avatar = avatar
		self.phone = phone
	}
	
	public let id: Int
	
	public let firstName: String
	
	public let lastName: String
	
	public let dOB: String
	
	public let email: String?
	
	public let avatar: String?
	
	public let phone: String?
	
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case firstName = "first_name"
		case lastName = "last_name"
		case dOB = "d_o_b"
		case email
		case avatar
		case phone
	}
	
}
