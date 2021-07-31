import ComposableArchitecture
import Tagged

public struct StepEntryHTMLFormInfo: Decodable, Equatable {
	public let possibleFormTemplates: IdentifiedArrayOf<FormTemplateInfo>
	
	//if step is not started both are nil
	public let chosenFormTemplateId: FormTemplateInfo.ID?
	public let formEntryId: FilledFormData.ID?
}

public struct StepEntry: Decodable, Equatable {
	
	public let stepType: StepType
	public let order: Int?
	public var status: StepStatus
	
	public let htmlFormInfo: StepEntryHTMLFormInfo?
	
	enum CodingKeys: String, CodingKey {
		case possibleFormTemplateNames = "possible_form_template_names"
		case chosenFormTemplateId = "chosen_form_template_id "
		case possibleFormTemplateIds = "possible_form_template_ids"
		case formEntryId = "form_entryid_id"
		case step_form_type
		case step_order
		case status
	}

public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let stepType = try container.decode(StepType.self, forKey: .step_form_type)
		self.stepType = stepType
		
        switch stepType {
        
        case .medicalhistory, .consents, .treatmentnotes, .prescriptions:
            self.htmlFormInfo = try parseHtmlFormInfo(container, stepType)
			
        default:
			self.htmlFormInfo = nil
		}
		
		self.order = Int(try container.decode(String.self, forKey: .step_order))
        self.status = (try? container.decode(StepStatus.self, forKey: .status)) ?? .pending
	}
}

fileprivate func parseHtmlFormInfo(_ container: KeyedDecodingContainer<StepEntry.CodingKeys>, _ stepType: StepType) throws -> StepEntryHTMLFormInfo {
    
    let formEntryId: FilledFormData.ID?
    let chosenTemplateId: HTMLForm.ID?
    
    let formEntryId2 = try container.decode(Int.self, forKey: .formEntryId)
    formEntryId = formEntryId2 != 0 ? .init(rawValue: formEntryId2) : nil
    let chosenTemplateId2 = try container.decode(EitherStringOrInt.self, forKey: .chosenFormTemplateId).integerValue
    chosenTemplateId = chosenTemplateId2 != 0 ? .init(rawValue: chosenTemplateId2) : nil
    
    let possibleFormTemplates: [FormTemplateInfo]
    
    if let possibleFormTemplateIds = try? container.decode([FormTemplateInfo.ID].self, forKey: .possibleFormTemplateIds),
       let possFormTemplateNames = try? container.decode([String].self, forKey: .possibleFormTemplateNames) {
        let formType = FormType.init(stepType: stepType)!
        possibleFormTemplates = zip(possibleFormTemplateIds, possFormTemplateNames)
            .compactMap { FormTemplateInfo.init(id: $0.0, name: $0.1, type: formType) }
    } else {
        possibleFormTemplates = []
    }
    
    return StepEntryHTMLFormInfo(possibleFormTemplates: IdentifiedArrayOf(uniqueElements: possibleFormTemplates),
                                 chosenFormTemplateId: chosenTemplateId,
                                 formEntryId: formEntryId)
}
