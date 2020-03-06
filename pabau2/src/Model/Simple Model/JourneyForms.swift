//
// JourneyForms.swift

import Foundation


public struct JourneyForms: Codable, Identifiable {

    public let id: Int

    public let formTemplateId: Int?
    
    public enum CodingKeys: String, CodingKey { 
        case id
        case formTemplateId = "form_templateid"
    }

}
