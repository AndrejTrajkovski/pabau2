//
// AppointmentStatus.swift

import Foundation


public struct AppointmentStatus: Codable, Identifiable {

    public let id: Int?

    public let name: String?
    public init(id: Int? = nil, name: String? = nil) { 
        self.id = id
        self.name = name
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case name
    }

}
