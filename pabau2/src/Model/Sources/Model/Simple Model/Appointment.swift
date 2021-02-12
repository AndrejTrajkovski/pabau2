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
}
