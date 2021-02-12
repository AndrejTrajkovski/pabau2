import Foundation

public struct HTMLFormInfo: Codable, Identifiable, Equatable {
	public let id: HTMLForm.ID
	public let name: String
	public let type: FormType
	
	enum CodingKeys: String, CodingKey {
		case id
		case name = "form_name"
		case type = "form_type"
	}
}
