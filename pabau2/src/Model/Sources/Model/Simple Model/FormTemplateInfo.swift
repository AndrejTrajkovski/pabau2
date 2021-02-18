import Foundation
import Tagged

public struct FormTemplateInfo: Codable, Identifiable, Equatable {
	
	public typealias ID = Tagged<FormTemplateInfo, String>
	
	public let id: FormTemplateInfo.ID
	public let name: String
	public let type: FormType
	
	enum CodingKeys: String, CodingKey {
		case id
		case name = "form_name"
		case type = "form_type"
	}
}
