import Tagged

public struct PathwayInfo: Decodable, Equatable, Identifiable {
    public init(_ pathway: Pathway, _ template: PathwayTemplate) {
        self.pathwayTemplateId = template.id
        self.pathwayId = pathway.id
        self.stepsTotal = template.steps.count
        self.stepsComplete = pathway.stepEntries.filter { $0.value.status != .pending }.count
    }
    
    public var id: Pathway.ID { pathwayId }
    public let pathwayTemplateId: PathwayTemplate.ID
    public let pathwayId: Pathway.ID
    public var stepsTotal: Int
    public var stepsComplete: Int
    
    enum CodingKeys: String, CodingKey {
        case pathwayTemplateId = "pathway_template_id"
        case pathwayId = "pathway_id"
        case stepsTotal = "steps_total"
        case stepsComplete = "steps_complete"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        let parseId = try container.decode(EitherStringOrInt.self, forKey: .pathwayId)
        self.pathwayId = Pathway.ID.init(rawValue: parseId.integerValue)
        let templateId = try container.decode(EitherStringOrInt.self, forKey: .pathwayTemplateId)
        self.pathwayTemplateId = PathwayTemplate.ID.init(rawValue: templateId.integerValue)
        self.stepsTotal = try container.decode(EitherStringOrInt.self, forKey: .stepsTotal).integerValue
        self.stepsComplete = try container.decode(EitherStringOrInt.self, forKey: .stepsComplete).integerValue
    }
}
