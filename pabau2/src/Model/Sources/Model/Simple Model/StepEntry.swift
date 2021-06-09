import ComposableArchitecture
import Tagged

public struct StepEntryFormInfo: Decodable, Equatable {
	public let possibleFormTemplates: IdentifiedArrayOf<FormTemplateInfo>
	
	//if step is not started both are nil
	public let chosenFormTemplateId: FormTemplateInfo.ID?
	public let formEntryId: FilledFormData.ID?
	
	
	public var templateIdToLoad: FormTemplateInfo.ID? {
		if let chosenFormTemplateId = chosenFormTemplateId {
			return chosenFormTemplateId
		} else if possibleFormTemplates.count == 1 {
			return possibleFormTemplates.first!.id
		} else {
			return nil
		}
	}
}

public struct StepEntry: Decodable, Equatable {
	
//	public typealias ID = Tagged<Step.ID, String>
	public let stepType: StepType
	public let order: Int?
	public let status: StepStatus
	
	public let htmlFormInfo: StepEntryFormInfo?
	
	enum CodingKeys: String, CodingKey {
		case possibleFormTemplateNames = "possible_form_template_names"
		case chosenFormTemplateId = "chosen_form_template_id"
		case possibleFormTemplateIds = "possible_form_template_ids"
		case formEntryId = "form_entry_id"
		case step_form_type
		case step_order
		case status
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let stepType = try container.decode(StepType.self, forKey: .step_form_type)
		self.stepType = stepType
		
		if stepType.isHTMLForm {
			
			let formEntryId: FilledFormData.ID?
			let chosenTemplateId: HTMLForm.ID?
			
			if let formEntryId2 = try? container.decode(FilledFormData.ID.self, forKey: .formEntryId),
			   formEntryId2.rawValue != 0,
			   let chosenTemplateId2 = try? container.decode(HTMLForm.ID.self, forKey: .chosenFormTemplateId),
			   chosenTemplateId2.description != "0" {
				
				formEntryId = FilledFormData.ID?.some(.init(rawValue: formEntryId2.rawValue))
				chosenTemplateId = chosenTemplateId2
				
			} else {
				
				formEntryId = nil
				chosenTemplateId = nil
			}
			
			let possibleFormTemplates: [FormTemplateInfo]
			
			if let possibleFormTemplateIds = try? container.decode([FormTemplateInfo.ID].self, forKey: .possibleFormTemplateIds),
				  let possFormTemplateNames = try? container.decode([String].self, forKey: .possibleFormTemplateNames) {
				let formType = FormType.init(stepType: stepType)!
				possibleFormTemplates = zip(possibleFormTemplateIds, possFormTemplateNames)
					.compactMap { FormTemplateInfo.init(id: $0.0, name: $0.1, type: formType) }
			} else {
				possibleFormTemplates = []
			}
			
			self.htmlFormInfo = StepEntryFormInfo(possibleFormTemplates: IdentifiedArrayOf(possibleFormTemplates),
												  chosenFormTemplateId: chosenTemplateId,
												  formEntryId: formEntryId)
			
		} else {
			self.htmlFormInfo = nil
		}
		
		self.order = Int(try container.decode(String.self, forKey: .step_order))
		self.status = .pending//TODO
//		self.id = try container.decode(StepEntry.ID.self, forKey: .id)
	}
}
