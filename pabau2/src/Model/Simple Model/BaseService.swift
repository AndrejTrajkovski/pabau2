//
// BaseService.swift

import Foundation


public struct BaseService: Codable, Identifiable {

    public let id: Int

    public let name: String

    public let color: String
    public init(id: Int, name: String, color: String) { 
        self.id = id
        self.name = name
        self.color = color
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case name
        case color
    }

}
