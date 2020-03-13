//
// Location.swift

import Foundation

public struct Location: Codable, Identifiable {

    public let id: Int

    public let name: String?
    public init(id: Int, name: String? = nil) {
        self.id = id
        self.name = name
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
    }

}
