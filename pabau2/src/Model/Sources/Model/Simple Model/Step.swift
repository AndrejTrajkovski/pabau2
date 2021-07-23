import Foundation
import Tagged

public struct Step: Decodable, Identifiable, Equatable {
	
	public typealias Id = Tagged<Step, EitherStringOrInt>
	
	public enum PreselectedTemplate: Equatable {
		case definedbyservice
		case template(HTMLForm.ID)
	}
	
	public let id: Id
	
	public let stepType: StepType
	
	public let preselectedTemplate: PreselectedTemplate?
    
    public let canSkip: Bool
	//	public let _required: Bool
	//
	//	public let preselectedTemplateType: PreselectedTemplateType?
	//
	//	public let formTemplate: [BaseFormTemplate]?
	
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case stepType = "step"
		case form_template_id = "item_id"
        case can_skip
		//		case _required = "required"
		//		case preselectedTemplateType
		//		case formTemplate
	}
    
    public init(id: Id, stepType: StepType, preselectedTemplate: PreselectedTemplate?,
                canSkip: Bool) {
        self.id = id
        self.stepType = stepType
        self.preselectedTemplate = preselectedTemplate
        self.canSkip = canSkip
    }
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		self.id = try container.decode(Self.ID.self, forKey: .id)
		let stepType = try container.decode(StepType.self, forKey: .stepType)
		self.stepType = stepType
        self.canSkip = ((try? container.decode(String.self, forKey: .can_skip)) ?? "") == "1"
		if stepType.isHTMLForm {
			let form_template_id = try? container.decode(HTMLForm.ID.self, forKey: .form_template_id)
			if let form_template_id = form_template_id,
			   form_template_id.description != "0" {
				self.preselectedTemplate = .template(form_template_id)
			} else {
				self.preselectedTemplate = .definedbyservice
			}
		} else {
			self.preselectedTemplate = nil
		}
	}
}
