public struct StepEntry: Decodable, Equatable {
	
	let formTemplateName: String
	public let formTemplateId: FormTemplateInfo.ID?
	public let formEntryId: FilledFormData.ID?
	
	enum CodingKeys: String, CodingKey {
		case formTemplateName = "form_template_name"
		case formTemplateIds = "form_template_ids"
		case formEntryId = "form_entry_id"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.formTemplateName = try container.decode(String.self, forKey: .formTemplateName)
		let templateIdsArray = try container.decode([FormTemplateInfo.ID].self, forKey: .formTemplateIds)
		self.formTemplateId = templateIdsArray.first
		self.formEntryId = try container.decode(FilledFormData.ID.self, forKey: .formEntryId)
	}
}
