import SwiftDate
import Tagged
import Foundation

public struct Appointment: Codable, Equatable, Hashable {

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public static var defaultEmpty: Appointment {
		Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, employeeInitials: "", locationId: 1, locationName: "London", status: AppointmentStatus.mock.randomElement()!, service: BaseService.defaultEmpty)
	}

	public typealias Id = Tagged<Appointment, String>
	
	public let id: Appointment.Id

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
	
	public let service: BaseService
	public init(id: String,
							from: Date,
							to: Date,
							employeeId: Int,
							employeeInitials: String,
							locationId: Int,
							locationName: String,
							_private: String? = nil,
							type: Termin.ModelType? = nil,
							extraEmployees: [Employee]? = nil,
							status: AppointmentStatus? = nil,
							service: BaseService) {
		self.id = Appointment.Id(rawValue: id)
		self.start_time = from
		self.end_time = to
		self.employeeId = Employee.Id(rawValue: employeeId)
		self.employeeInitials = employeeInitials
		self.locationId = String(locationId)
		self.locationName = locationName
		self._private = _private
		self.type = type
		self.extraEmployees = extraEmployees
		self.status = status
		self.service = service
	}
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

extension Appointment {
	public init(id: Int,
							from: Date,
							to: Date,
							employeeId: Int,
							employeeInitials: String,
							locationId: Int,
							locationName: String,
							_private: Bool? = nil,
							type: Termin.ModelType? = nil,
							extraEmployees: [Employee]? = nil,
							status: AppointmentStatus? = nil,
							service: BaseService) {
		self.init(id: String(id), from: from, to: to, employeeId: employeeId, employeeInitials: employeeInitials, locationId: locationId, locationName: locationName, service: service)
	}
}

extension Appointment {
	static let mockAppointments =
		[
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "London", service: BaseService.init(id: 1, name: "Botox", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "RU", locationId: 1, locationName: "Skopje", service: BaseService.init(id: 1, name: "Fillers", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "London", service: BaseService.init(id: 1, name: "Wax Job", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "Thailand", service: BaseService.init(id: 1, name: "Haircut", color: "#eb4034")),
			Appointment(id: 1,
									from: Date(),
									to: Date(),
									employeeId: 1,
									employeeInitials: "AT", locationId: 1, locationName: "Manchester", service: BaseService.init(id: 1, name: "Thai Massage", color: "#eb4034"))
	]
}
