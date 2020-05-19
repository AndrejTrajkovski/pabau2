//
// FormTemplate.swift

import Foundation

public struct FormTemplate: Codable, Identifiable, Equatable, Hashable, CustomDebugStringConvertible {
	
	public var canProceed: Bool {
		self.formStructure.formStructure.allSatisfy {
			$0._required ? $0.cssClass.isFulfilled : false
		}
	}
	
	public var debugDescription: String {
			return name
	}
	
	public static var defaultEmpty: FormTemplate {
		return FormTemplate(id: -1,
												name: "", formType: .consent, ePaper: false, formStructure: FormStructure.defaultEmpty)
	}

    public let id: Int

    public let name: String

    public let formType: FormType

    public let ePaper: Bool?

    public var formStructure: FormStructure
    public init(id: Int, name: String, formType: FormType, ePaper: Bool? = nil, formStructure: FormStructure) {
        self.id = id
        self.name = name
        self.formType = formType
        self.ePaper = ePaper
        self.formStructure = formStructure
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case formType = "form_type"
        case ePaper
        case formStructure = "form_structure"
    }

}
