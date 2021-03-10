import Tagged

public struct Employee: Decodable, Identifiable, Equatable, Hashable {
	public typealias Id = Tagged<Employee, String>
		
	public let id: Employee.Id
	
	public let name: String
	
	public let email: String
	
	public let avatar: String?
	
	public let locationId: Location.Id?
	
	public let passcode: String
    
    public let locations: String?
	
	enum CodingKeys: String, CodingKey {
		case id
		case name = "full_name"
		case email, avatar
		case passcode
		case locationId
        case locations
	}
}
