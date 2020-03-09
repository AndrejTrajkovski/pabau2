//
// Employee.swift

import Foundation


public struct Employee: Codable, Identifiable, Equatable {


    public let id: Int

    public let name: String

    public let avatarUrl: String?

    public let pin: Int?
    public init(id: Int, name: String, avatarUrl: String? = nil, pin: Int? = nil) { 
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.pin = pin
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case name
        case avatarUrl = "avatar_url"
        case pin
    }

}
