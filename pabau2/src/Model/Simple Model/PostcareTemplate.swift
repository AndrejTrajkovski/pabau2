//
// PostcareTemplate.swift

import Foundation


public struct PostcareTemplate: Codable, Identifiable {

    public enum TemplateType: String, Codable { 
        case sms = "sms"
        case email = "email"
    }

    public let id: Int

    public let type: PostcareType
    public let templateType: TemplateType

    public let image: String

    public let connected: Bool
    public init(id: Int, type: PostcareType, templateType: TemplateType, image: String, connected: Bool) { 
        self.id = id
        self.type = type
        self.templateType = templateType
        self.image = image
        self.connected = connected
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case type
        case templateType = "template_type"
        case image
        case connected
    }

}
