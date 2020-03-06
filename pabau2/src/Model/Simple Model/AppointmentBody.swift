import Foundation

public struct AppointmentBody: Codable {

    public let employeeId: Int?

    public let serviceId: Int?

    public let from: Date?

    public let toDate: Date?

    public let helpersIds: [Int]?
    public init(employeeId: Int? = nil, serviceId: Int? = nil, from: Date? = nil, toDate: Date? = nil, helpersIds: [Int]? = nil) {
        self.employeeId = employeeId
        self.serviceId = serviceId
        self.from = from
        self.toDate = toDate
        self.helpersIds = helpersIds
    }
    public enum CodingKeys: String, CodingKey { 
        case employeeId = "employeeid"
        case serviceId = "serviceid"
        case from
        case toDate = "to"
        case helpersIds = "helpersids"
    }

}
