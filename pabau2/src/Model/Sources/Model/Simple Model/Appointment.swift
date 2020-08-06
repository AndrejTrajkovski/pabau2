//
// Appointment.swift

import Foundation
import SwiftDate

public struct Appointment: Codable, Equatable {

	public static var defaultEmpty: Appointment {
		Appointment.init(id: 1, from: Date() - 1.days, to: Date() - 1.days, employeeId: 1, employeeInitials: "", locationId: 1, locationName: "London", status: AppointmentStatus(id: 1, name: ""), service: BaseService.defaultEmpty)
	}

	public var id: Int

	public var from: Date

	public var to: Date

	public var employeeId: Int
	
	public var employeeInitials: String
	
	public var locationId: Int
	public var locationName: String

	public var _private: Bool?
	public var type: Termin.ModelType?

	public var extraEmployees: [Employee]?

	public var status: AppointmentStatus?
	
	public var service: BaseService
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
		self.id = id
		self.from = from
		self.to = to
		self.employeeId = employeeId
		self.employeeInitials = employeeInitials
		self.locationId = locationId
		self.locationName = locationName
		self._private = _private
		self.type = type
		self.extraEmployees = extraEmployees
		self.status = status
		self.service = service
	}
	public enum CodingKeys: String, CodingKey {
		case id
		case from
		case to
		case employeeId = "employee_id"
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
