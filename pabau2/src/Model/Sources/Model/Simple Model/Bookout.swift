import Foundation
import Tagged

public struct Bookout: Codable, Identifiable {
	
	public typealias Id = Tagged<Bookout, Int>
	
	public let id: Bookout.Id
	
	public let from: Date
	
	public let to: Date
	
	public let employeeId: Int
	
	public let locationId: Int
	
	public let _private: Bool?
	public let type: Termin.ModelType?
	
	public let extraEmployees: [Employee]?
	
	public let _description: String?
	
	public let externalGuests: String?
	public init(id: Int, from: Date, to: Date, employeeId: Int, locationId: Int, _private: Bool? = nil, type: Termin.ModelType? = nil, extraEmployees: [Employee]? = nil, _description: String? = nil, externalGuests: String? = nil) {
		self.id = Bookout.Id(rawValue: id)
		self.from = from
		self.to = to
		self.employeeId = employeeId
		self.locationId = locationId
		self._private = _private
		self.type = type
		self.extraEmployees = extraEmployees
		self._description = _description
		self.externalGuests = externalGuests
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case from
		case to
		case employeeId = "employeeid"
		case locationId = "locationid"
		case _private = "private"
		case type
		case extraEmployees = "extra_employees"
		case _description = "description"
		case externalGuests = "external_guests"
	}
	
}
