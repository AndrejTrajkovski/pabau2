import SwiftDate
import Tagged
import Foundation

public struct Appointment: Codable, Equatable {
	public typealias Id = Tagged<Appointment, Int>
	
	public let id: Appointment.Id
    
    public let startDate: Date

	public let startTime: Date

	public let endTime: Date

	public var type: Termin.ModelType? = nil

	public var extraEmployees: [Employee]? = nil

	public var status: AppointmentStatus? = nil

	public var service: BaseService? = nil
    
    public var employeeName: String = ""
    
    public let appointmentService: String
    
    public var employeeInitials: String {
        let separatedEmployeeName = employeeName.components(separatedBy: " ")
        return separatedEmployeeName.map { $0.prefix(1) }.joined()
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case startDate = "start_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case type
        case extraEmployees = "extra_employees"
        case employeeName = "employee_name"
        case status
        case service
        case appointmentService = "appointment_service"
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
