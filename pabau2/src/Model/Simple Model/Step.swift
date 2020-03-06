//
// Step.swift

import Foundation

/** If a Step object \&quot;stepType\&quot; property value is \&quot;consents\&quot; or \&quot;treatmentNotes\&quot;, and its \&quot;preselectedTemplateType\&quot; property value is \&quot;template\&quot;, that Step object will have a value for the \&quot;formTemplate\&quot; property. If a Step object \&quot;stepType\&quot; property value is not \&quot;consents\&quot; nor \&quot;treatmentNotes\&quot;, then both \&quot;preselectedTemplateType\&quot; and \&quot;template\&quot; will not be returned. */
public struct Step: Codable, Identifiable {

    public enum PreselectedTemplateType: String, Codable { 
        case definedbyservice = "definedByService"
        case template = "template"
    }

    public let id: Int

    public let stepType: StepType

    public let _required: Bool
    public let preselectedTemplateType: PreselectedTemplateType?

    public let formTemplate: [BaseFormTemplate]?
    public init(id: Int, stepType: StepType, _required: Bool, preselectedTemplateType: PreselectedTemplateType? = nil, formTemplate: [BaseFormTemplate]? = nil) { 
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
