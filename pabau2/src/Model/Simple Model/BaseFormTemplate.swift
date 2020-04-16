//
// BaseFormTemplate.swift

import Foundation

public struct BaseFormTemplate: Codable, Identifiable, Equatable {
	
	public let id: Int
	
	public let name: String
	
	public let formType: FormType
	
	public let ePaper: Bool?
	public init(id: Int, name: String, formType: FormType, ePaper: Bool? = nil) {
		self.id = id
		self.name = name
		self.formType = formType
		self.ePaper = ePaper
	}
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case name
		case formType = "form_type"
		case ePaper
	}
}
