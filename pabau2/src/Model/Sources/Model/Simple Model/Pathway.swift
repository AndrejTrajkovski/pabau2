import Tagged

public struct Pathway: Decodable, Identifiable, Equatable {
	
	public typealias ID = Tagged<Pathway, EitherStringOrInt>
	
	public let id: ID
	
	public let stepEntries: Dictionary<Step.Id, StepEntry>
	
	enum CodingKeys: String, CodingKey {
		case id
		case stepEntries
	}
	
	public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(Self.ID.self, forKey: .id)
		let stepEntries = try container.decode(FailableCodableDictionary<StepEntry, String>.self, forKey: .stepEntries).dictionary
		self.stepEntries = stepEntries.mapKeys {
			Step.Id.init(rawValue: EitherStringOrInt.left($0))
		}
	}
}
