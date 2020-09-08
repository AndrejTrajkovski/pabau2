import Tagged
import Foundation

public struct CalendarResponse: Codable {
//	public let rota: [Employee.Id: [Shift]]
	public let appointments: [CalAppointment]
}

public struct CalAppointment: Hashable, Codable {

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}

	public typealias Id = Tagged<CalAppointment, String>
	
	public let id: CalAppointment.Id

	public let start_time: Date

	public let end_time: Date

	public let employeeId: Employee.Id
	
	public let employeeInitials: String?
	
	public let locationId: String
	public let locationName: String?

	public let _private: String?
	public let type: Termin.ModelType?

	public let extraEmployees: [Employee]?

	public let status: AppointmentStatus?
	
	public let service: String
	
	public enum CodingKeys: String, CodingKey {
		case id
		case start_time
		case end_time
		case employeeId = "user_id"
		case employeeInitials = "employee_initials"
		case locationId = "location_id"
		case locationName = "location_name"
		case _private = "private"
		case type
		case extraEmployees = "extra_employees"
		case status
		case service
	}
}
