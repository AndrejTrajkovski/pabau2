//
// Media.swift

import Foundation

public struct Media: Codable, Identifiable, Equatable {

    public enum ModelType: String, Codable {
        case photo = "photo"
        case video = "video"
    }

    public let id: Int

    public let url: String
    public let type: ModelType
    public init(id: Int, url: String, type: ModelType) {
        self.id = id
        self.url = url
        self.type = type
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case url
        case type
    }

}
