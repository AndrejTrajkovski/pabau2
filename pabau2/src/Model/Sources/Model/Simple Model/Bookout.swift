import Foundation
import Tagged

public struct Bookout: Codable, Identifiable {
	
	public let id: CalendarEvent.Id
	public var start_date: Date
	public var end_date: Date
	public var employeeId: Employee.ID
	public var locationId: Location.ID
	public let _private: Bool?
	public let _description: String?
	var employeeInitials: String?
	var locationName: String?
	var employeeName: String
	
//	public let externalGuests: String?
	public init(id: CalendarEvent.Id,
				start_date: Date,
				end_date: Date,
				employeeId: Employee.ID,
				locationId: Location.ID,
				_private: Bool? = nil,
				_description: String? = nil,
				employeeName: String) {
		self.id = id
		self.start_date = start_date
		self.end_date = end_date
		self.employeeId = employeeId
		self.locationId = locationId
		self._private = _private
		self._description = _description
		self.employeeName = employeeName
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case start_date
		case end_date
		case employeeId = "employeeid"
		case locationId = "locationid"
		case _private = "private"
		case _description = "description"
//		case externalGuests = "external_guests"
		case employeeName = "employee_name"
		case employeeInitials = "employee_initials"
	}
}

extension Bookout: CalendarEventVariant {
}

extension Bookout {
	public init(
		_ id: CalendarEvent.Id,
		_ start_date: Date,
		_ end_date: Date,
		_ employeeId: Employee.Id,
		_ employeeInitials: String?,
		_ locationId: Location.Id,
		_ locationName: String?,
		_ _private: Bool?,
		_ employeeName: String,
		_ decoder: Decoder
	) throws {
		self.id = id
		self.start_date = start_date
		self.end_date = end_date
		self.employeeId = employeeId
		self.employeeInitials = employeeInitials
		self.locationId = locationId
		self.locationName = locationName
		self._private = _private
		self.employeeName = employeeName
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self._description = try? container.decode(String.self, forKey: ._description)
	}
}
