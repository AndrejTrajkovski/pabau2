public struct StepEntry: Decodable, Equatable {
	
	let formTemplateName: String
	public let formTemplateId: FormTemplateInfo.ID?
	public let formEntryId: FilledFormData.ID?
	public let stepType: StepType
	public let order: Int
	
	enum CodingKeys: String, CodingKey {
		case formTemplateName = "form_template_name"
		case formTemplateIds = "form_template_ids"
		case formEntryId = "form_entry_id"
		case step_form_type
		case step_order
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.formTemplateName = try container.decode(String.self, forKey: .formTemplateName)
		let templateIdsArray = try container.decode([FormTemplateInfo.ID].self, forKey: .formTemplateIds)
		self.formTemplateId = templateIdsArray.first
		let formEntryId = try container.decode(FilledFormData.ID.self, forKey: .formEntryId)
		self.formEntryId = formEntryId.rawValue == 0 ? FilledFormData.ID?.none : FilledFormData.ID?.some(.init(rawValue: formEntryId.rawValue))
		self.stepType = try container.decode(StepType.self, forKey: .step_form_type)
		self.order = try container.decode(Int.self, forKey: .step_order)
	}
}
