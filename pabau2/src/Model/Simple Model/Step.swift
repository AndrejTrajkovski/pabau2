//
// Step.swift

import Foundation

/** If a Step object stepType  property value is consents  or treatmentNotes , and its preselectedTemplateType  property value istemplate , that Step object will have a value for theformTemplate  property. If a Step objectstepType  property value is not consents  nor treatmentNotes , then both preselected TemplateType  and template  will not be returned. */
public struct Step: Codable, Identifiable, Equatable {

    public enum PreselectedTemplateType: String, Codable, Equatable {
        case definedbyservice = "definedByService"
        case template = "template"
    }

    public let id: Int

    public let stepType: StepType

    public let _required: Bool
    public let preselectedTemplateType: PreselectedTemplateType?

    public let formTemplate: [BaseFormTemplate]?
    public init(id: Int, stepType: StepType, _required: Bool = false, preselectedTemplateType: PreselectedTemplateType? = nil, formTemplate: [BaseFormTemplate]? = nil) {
        self.id = id
        self.stepType = stepType
        self._required = _required
        self.preselectedTemplateType = preselectedTemplateType
        self.formTemplate = formTemplate
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case stepType
        case _required = "required"
        case preselectedTemplateType
        case formTemplate
    }

}
