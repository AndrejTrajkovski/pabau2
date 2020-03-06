//
// Termin.swift

import Foundation

/** Abstract superclass for Appointment and Bookout. */
public struct Termin: Codable, Identifiable {

    public enum ModelType: String, Codable { 
        case appointment = "appointment"
        case bookout = "bookout"
    }

    public let id: Int

    public let from: Date

    public let to: Date

    public let employeeId: Int

    public let locationId: Int

    public let _private: Bool?
    public let type: ModelType?

    public let extraEmployees: [Employee]?
    public init(id: Int, from: Date, to: Date, employeeId: Int, locationId: Int, _private: Bool? = nil, type: ModelType? = nil, extraEmployees: [Employee]? = nil) { 
        self.id = id
        self.from = from
        self.to = to
        self.employeeId = employeeId
        self.locationId = locationId
        self._private = _private
        self.type = type
        self.extraEmployees = extraEmployees
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case from
        case to
        case employeeId = "employeeid"
        case locationId = "locationid"
        case _private = "private"
        case type
        case extraEmployees = "extra_employees"
    }

}
