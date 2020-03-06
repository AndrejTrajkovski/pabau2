//
// Shift.swift

import Foundation


public struct Shift: Codable, Identifiable {


    public let id: Int?

    public let employeeId: Int?

    public let userId: Int?

    public let locationId: Int?

    public let date: Date?

    public let startTime: Date?

    public let endTime: Date?

    public let published: Bool?
    public init(id: Int? = nil, employeeId: Int? = nil, userId: Int? = nil, locationId: Int? = nil, date: Date? = nil, startTime: Date? = nil, endTime: Date? = nil, published: Bool? = nil) { 
        self.id = id
        self.employeeId = employeeId
        self.userId = userId
        self.locationId = locationId
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.published = published
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case employeeId = "employeeid"
        case userId = "userid"
        case locationId = "locationid"
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case published
    }

}
