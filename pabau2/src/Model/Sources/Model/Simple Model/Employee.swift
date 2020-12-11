//
// Employee.swift
import Tagged

public struct Employee: Codable, Identifiable, Equatable, Hashable {
	public typealias Id = Tagged<Employee, Int>
	
	public static var defaultEmpty: Employee {
		Employee.init(id: -1, name: "", locationId: 1)
	}
	
	public let id: Employee.Id
	
	public let name: String
	
	public let avatarUrl: String?
	
	public let locationId: Location.Id?
	
	public let pin: Int?
	public init(id: Int,
				name: String,
				avatarUrl: String? = nil,
				pin: Int? = nil,
				locationId: Int) {
		self.init(id: id, name: name, avatarUrl: avatarUrl, pin: pin, locationId: Location.Id(rawValue: locationId))
	}
	
	public init(id: Int,
				name: String,
				avatarUrl: String? = nil,
				pin: Int? = nil,
				locationId: Location.Id) {
		self.id = Employee.Id(rawValue: id)
		self.name = name
		self.avatarUrl = avatarUrl
		self.pin = pin
		self.locationId = locationId
	}
	
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case name
		case avatarUrl = "avatar_url"
		case pin
		case locationId = "location_id"
	}
	
}

extension Employee {
	public static let mockEmployees = [
		Employee.init(id: 1,
					  name: "Dr. Jekil",
					  avatarUrl: "asd",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 3,
					  name: "Michael Jordan",
					  avatarUrl: "",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 4,
					  name: "Kobe Bryant",
					  avatarUrl: "",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 6,
					  name: "Britney Spears",
					  avatarUrl: "",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 7,
					  name: "Dr. Who",
					  avatarUrl: "",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 8,
					  name: "Dr. Huberman",
					  avatarUrl: "",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 11,
					  name: "Dr. Andrej",
					  avatarUrl: "asd",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 31,
					  name: "Dr. Floki",
					  avatarUrl: "",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		),
		Employee.init(id: 41,
					  name: "Dr. Billy",
					  avatarUrl: "",
					  pin: 1234,
					  locationId: Location.mock().randomElement()!.id.rawValue
		)
	]
	
}
