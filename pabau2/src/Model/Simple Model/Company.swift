//
// Company.swift

import Foundation

public struct Company: Codable, Identifiable, Equatable {

    public let id: Int

    public let name: String

    public let logo: String

    public let pins: [Int]?

    public let backgroundImage: String?

    /** Ask why this is different! */
    public let userId: Int?

    public let buttonCol: String?

    /** Paired with user. */
    public let apiKey: String?

    /** Paired with user. */
    public let expired: Bool?
    public init(id: Int, name: String, logo: String, pins: [Int]? = nil, backgroundImage: String? = nil, userId: Int? = nil, buttonCol: String? = nil, apiKey: String? = nil, expired: Bool? = nil) {
        self.id = id
        self.name = name
        self.logo = logo
        self.pins = pins
        self.backgroundImage = backgroundImage
        self.userId = userId
        self.buttonCol = buttonCol
        self.apiKey = apiKey
        self.expired = expired
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case logo
        case pins
        case backgroundImage = "background_image"
        case userId = "userid"
        case buttonCol = "button_col"
        case apiKey = "api_key"
        case expired
    }

}
