import SwiftDate
import Tagged
import Foundation

public struct Appointment: Codable, Equatable, Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static var defaultEmpty: Appointment {
        Appointment.init(
            id: 1, from: Date() - 1.days,
            to: Date() - 1.days,
            employeeId: 1,
            employeeInitials: "",
            locationId: 1,
            locationName: "London",
            status: AppointmentStatus.mock.randomElement()!,
            service: BaseService.defaultEmpty
        )
    }

    public typealias Id = Tagged<Appointment, Int>

    public let id: Appointment.Id
    
    public let startDate: Date

    public let startTime: Date

    public let endTime: Date

    public var type: Termin.ModelType? = nil

    public var extraEmployees: [Employee]? = nil

    public var status: AppointmentStatus? = nil

    public let status: AppointmentStatus?

    public let service: BaseService?

    public var employeeInitials: String {
        let separatedEmployeeName = employeeName.components(separatedBy: " ")
        return separatedEmployeeName.map { $0.prefix(1) }.joined()
    }
    
    public init(
        id: Int,
        from: Date,
        to: Date,
        employeeId: Int,
        employeeInitials: String,
        locationId: Location.Id,
        locationName: String,
        _private: String? = nil,
        type: Termin.ModelType? = nil,
        extraEmployees: [Employee]? = nil,
        status: AppointmentStatus? = nil,
        service: BaseService
    ) {
        self.id = Appointment.Id(rawValue: id)
        self.from = from.toString(.sql)
        self.to = to.toString(.sql)
        self.employeeId = Employee.Id(rawValue: employeeId)
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
        case locationId = "location_id"
        case locationName = "location_name"
        case _private = "private"
        case type
        case extraEmployees = "extra_employees"
        case status
        case service
        case appointmentService = "appointment_service"
        case employeeName = "employee_name"
        case startDate = "start_date"
        case startTime = "start_time"
        case endTime = "end_time"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let sId = try? container.decode(String.self, forKey: .id), let id = Int(sId) {
            self.id = Appointment.Id(rawValue: id)
        } else {
            throw RequestError.jsonDecoding("Id invalid")
        }
        
        if let startDate = try? container.decode(String.self, forKey: .startDate), let start = Date(startDate) {
            self.startDate = start
        } else {
            self.startDate = Date()
        }
        
        if let start = try? container.decode(String.self, forKey: .startTime), let startDate = try? container.decode(String.self, forKey: .startDate) {
            let startTime = "\(startDate) \(start)"
            self.startTime = Date(startTime) ?? Date()
        } else {
            self.startTime = Date()
        }
        
        if let endTime = try container.decodeIfPresent(String.self, forKey: .endTime),  let startDate = try container.decodeIfPresent(String.self, forKey: .startDate) {
            let end = "\(startDate) \(endTime)"
            self.endTime = Date(end) ?? Date()
        } else {
            self.endTime = Date()
        }
        
        self.appointmentService = try container.decode(String.self, forKey: .appointmentService)
        self.employeeName = try container.decode(String.self, forKey: .employeeName)
        
    }
    
    public static func ==(lhs: Appointment, rhs: Appointment) -> Bool {
        return lhs.id == rhs.id
    }
    
    public init(id: Int,
                from: Date,
                to: Date,
                employeeInitials: String,
                locationId: Location.Id,
                locationName: String,
                _private: String? = nil,
                type: Termin.ModelType? = nil,
                extraEmployees: [Employee]? = nil,
                status: AppointmentStatus? = nil,
                service: BaseService,
                serviceName: String = "") {
        self.id = Appointment.Id(rawValue: id)
        self.startTime = from
        self.endTime = to
        self.startDate = from
        self.type = type
        self.extraEmployees = extraEmployees
        self.status = status
        self.service = service
        self.appointmentService = serviceName
    }
}
