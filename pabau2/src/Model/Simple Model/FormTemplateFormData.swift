//
// FormTemplateFormData.swift

import Foundation

public struct FormTemplateFormData: Codable {


    public let formStructure: [CSSField]?
    public init(formStructure: [CSSField]? = nil) { 
        self.formStructure = formStructure
    }
    public enum CodingKeys: String, CodingKey { 
        case formStructure = "form_structure"
    }

}
