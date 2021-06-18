import Foundation
import Tagged

public struct FormTemplateInfo: Decodable, Identifiable, Equatable {
	
	public init(id: HTMLForm.ID, name: String, type: FormType) {
		self.id = id
		self.name = name
		self.type = type
	}
	
	public let id: HTMLForm.ID
	public let name: String
	public let type: FormType
	
	enum CodingKeys: String, CodingKey {
		case id
		case name = "form_name"
		case type = "form_type"
	}
}
