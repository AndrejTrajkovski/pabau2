import Foundation
import Tagged

public struct PathwayTemplate: Decodable, Identifiable, Equatable {

	public typealias ID = Tagged<PathwayTemplate, EitherStringOrInt>
	
    public let id: ID

    public let title: String

    public let steps: [Step]

    public let _description: String?
	
    public init(id: Int, title: String, steps: [Step], _description: String? = nil) {
		self.id = Self.ID.init(rawValue: .right(id))
        self.title = title
        self.steps = steps
        self._description = _description
    }
    
    public init(id: ID, title: String, steps: [Step], _description: String? = nil) {
        self.id = id
        self.title = title
        self.steps = steps
        self._description = _description
    }
	
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "pathway_name"
        case steps
        case _description = "description"
    }
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		self.id = try container.decode(Self.ID.self, forKey: .id)
		self.title = try container.decode(String.self, forKey: .title)
		self.steps = try container.decode([Step].self, forKey: .steps)
		self._description = try container.decode(String.self, forKey: ._description)
	}
}
