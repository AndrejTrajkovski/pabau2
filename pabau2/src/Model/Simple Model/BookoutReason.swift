//
// BookoutReason.swift

import Foundation

public struct BookoutReason: Codable, Identifiable {

    public let id: Int?

    public let name: String?

    public let color: String?
    public init(id: Int? = nil, name: String? = nil, color: String? = nil) {
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
