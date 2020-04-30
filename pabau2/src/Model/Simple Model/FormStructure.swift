//
// FormTemplateFormData.swift

import Foundation

public struct FormStructure: Codable, Equatable, Hashable {

	public static var defaultEmpty: FormStructure {
		FormStructure(formStructure: [])
	}

	public var formStructure: [CSSField]
	public init(formStructure: [CSSField]) {
		self.formStructure = formStructure
	}
	public enum CodingKeys: String, CodingKey {
		case formStructure = "form_structure"
	}
}
