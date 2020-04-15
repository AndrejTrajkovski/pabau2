//
// FormTemplateFormData.swift

import Foundation

public struct FormStructure: Codable, Equatable {

    public let formStructure: [String]?
    public init(formStructure: [String]? = nil) {
        self.formStructure = formStructure
    }
    public enum CodingKeys: String, CodingKey {
        case formStructure = "form_structure"
    }
}
