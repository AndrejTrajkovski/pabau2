import Tagged

public struct Pathway: Decodable, Identifiable, Equatable {
	
	public typealias ID = Tagged<Pathway, Int>
	
	public let id: ID
	
	public let stepEntries: Dictionary<Step.Id, StepEntry>
	
	enum CodingKeys: String, CodingKey {
		case id
		case stepEntries
	}
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
        let parseId = try container.decode(EitherStringOrInt.self, forKey: .id)
        self.id = Self.ID.init(rawValue: parseId.integerValue)
//		let stepEntries = try container.decode(FailableCodableDictionary<String, StepEntry>.self, forKey: .stepEntries).dictionary
		let stepEntries = try container.decode(Dictionary<String, StepEntry>.self, forKey: .stepEntries)
		self.stepEntries = stepEntries.mapKeys {
			Step.Id.init(rawValue: Int($0)!)
		}
	}
}
