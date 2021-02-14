import SwiftDate
import Tagged
import Foundation

public struct Appointment: Codable, Equatable {

    public typealias Id = Tagged<Appointment, Int>

    public let id: Appointment.Id

    public let start_time: Date

    public let end_time: Date

    public let employeeId: Employee.Id

    public let employeeInitials: String?

    public let locationId: Location.Id
    public let locationName: String?

    public let _private: String?
    public let type: Termin.ModelType?

    public let extraEmployees: [Employee]?

    public let status: AppointmentStatus?

    public let service: BaseService?

    public enum CodingKeys: String, CodingKey {
        case id
        case start_time = "from"
        case end_time = "to"
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
    
    public init(
        id: Appointment.Id = 74259718,
        start_time: Date = Date(),
        end_time: Date = Date(),
        employeeId: Employee.Id = "1",
        employeeInitials: String? = "employeeInitials",
        locationId: Location.Id = 1,
        locationName: String? = "locationName",
        _private: String? = nil,
        type: Termin.ModelType? = .appointment,
        extraEmployees: [Employee]? = nil,
        status: AppointmentStatus? = .init(id: 1, name: "TEST", color: "COLOR"),
        service: BaseService? = BaseService.defaultEmpty
    ) {
        self.id = id
        self.start_time = start_time
        self.end_time = end_time
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
}
