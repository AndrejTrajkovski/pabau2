public struct StepEntry: Decodable, Equatable {
	
	public let formTemplateName: String
	public let formTemplateId: FormTemplateInfo.ID?
	public let formEntryId: FilledFormData.ID?
	public let stepType: StepType
	public let order: Int?
	public let status: StepStatus
	
	enum CodingKeys: String, CodingKey {
		case formTemplateName = "form_template_name"
		case formTemplateIds = "form_template_ids"
		case formEntryId = "form_entry_id"
		case step_form_type
		case step_order
		case status
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.formTemplateName = try container.decode(String.self, forKey: .formTemplateName)
		let templateIdsArray = try container.decode([FormTemplateInfo.ID].self, forKey: .formTemplateIds)
		self.formTemplateId = templateIdsArray.first
		if let formEntryId = try? container.decode(FilledFormData.ID.self, forKey: .formEntryId),
		   formEntryId.rawValue != 0 {
			self.formEntryId = FilledFormData.ID?.some(.init(rawValue: formEntryId.rawValue))
		} else {
			self.formEntryId = nil
		}
		
		self.stepType = try container.decode(StepType.self, forKey: .step_form_type)
		self.order = Int(try container.decode(String.self, forKey: .step_order))
		self.status = .pending//TODO
	}
}
