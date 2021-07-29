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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parseId = try container.decode(EitherStringOrInt.self, forKey: .id)
        self.id = Self.ID.init(rawValue: parseId.integerValue)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(FormType.self, forKey: .type)
    }
}
