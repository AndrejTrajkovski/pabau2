//
// BookoutReason.swift

import Foundation
import ComposableArchitecture
import Tagged

public struct BookoutReason: Decodable, Identifiable, Equatable {
    public var id: Int = 0
    public let name: String?
    public let color: String?
    
    public init(
        id: Int,
        name: String? = nil,
        color: String? = nil
    ) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = Int(id) ?? 0
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "room_name"
        case color = "block_color"
    }
}
