//
// JourneyPostCare.swift

import Foundation


public struct JourneyPostCare: Codable, Identifiable, Equatable {


    public let id: Int?

    public let templateId: Int?
    public init(id: Int? = nil, templateId: Int? = nil) { 
        self.id = id
        self.templateId = templateId
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case templateId = "templateid"
    }

}
