//
// Drawing.swift

import Foundation

/** Could be Chart or Stencil. */
public struct Drawing: Codable, Identifiable {

    public let id: Int?

    public let name: String?

    public let tags: [Tag]?
    public init(id: Int? = nil, name: String? = nil, tags: [Tag]? = nil) {
        self.id = id
        self.name = name
        self.tags = tags
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case tags
    }

}
