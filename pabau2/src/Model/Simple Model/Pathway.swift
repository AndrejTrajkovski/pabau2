//
// Pathway.swift

import Foundation

/** In the \&quot;steps\&quot; array of this object, if an element\\&#x27;s \&quot;stepType\&quot; property value is \&quot;consents\&quot; or \&quot;treatmentNotes\&quot;, and the \&quot;preselectedTemplateType\&quot; property value is \&quot;template\&quot;, that element will have a value for the \&quot;formTemplate\&quot; property. If an element\\&#x27;s \&quot;stepType\&quot; property value is not \&quot;consents\&quot; nor \&quot;treatmentNotes\&quot;, both the \&quot;preselectedTemplateType\&quot; and \&quot;formTemplate\&quot; will not be returned. */
public struct Pathway: Codable, Identifiable, Equatable {


    public let id: Int

    public let title: String

    public let steps: [Step]

    public let _description: String?
    public init(id: Int, title: String, steps: [Step], _description: String? = nil) { 
        self.id = id
        self.title = title
        self.steps = steps
        self._description = _description
    }
    public enum CodingKeys: String, CodingKey { 
        case id = "id"
        case title
        case steps
        case _description = "description"
    }

}
