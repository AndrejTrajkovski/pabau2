//
// FormTemplate.swift

import Foundation

public struct FormTemplate: Codable, Identifiable, Equatable {

    public let id: Int

    public let name: String

    public let formType: FormType

    public let ePaper: Bool?

    public let formData: FormTemplateFormData?
    public init(id: Int, name: String, formType: FormType, ePaper: Bool? = nil, formData: FormTemplateFormData? = nil) {
        self.id = id
        self.name = name
        self.formType = formType
        self.ePaper = ePaper
        self.formData = formData
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case formType = "form_type"
        case ePaper
        case formData = "form_data"
    }

}
