import Foundation
import Tagged

public struct Step: Codable, Identifiable, Equatable {
	
	public typealias Id = Tagged<Step, Int>
	
	public enum PreselectedTemplateType: String, Codable, Equatable {
		case definedbyservice = "definedByService"
		case template = "template"
	}

	public let id: Id

	public let stepType: StepType

//	public let _required: Bool
//
//	public let preselectedTemplateType: PreselectedTemplateType?
//
//	public let formTemplate: [BaseFormTemplate]?
	
	public init(id: Int, stepType: StepType, _required: Bool = false, preselectedTemplateType: PreselectedTemplateType? = nil, formTemplate: [BaseFormTemplate]? = nil) {
		self.id = Self.Id.init(rawValue: id)
		self.stepType = stepType
//		self._required = _required
//		self.preselectedTemplateType = preselectedTemplateType
//		self.formTemplate = formTemplate
	}
	
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case stepType = "step"
//		case _required = "required"
//		case preselectedTemplateType
//		case formTemplate
	}

}
