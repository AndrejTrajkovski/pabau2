import Foundation
import Tagged

public struct Location: Decodable, Identifiable, Equatable {

	public typealias Id = Tagged<Location, EitherStringOrInt>
	
    public let id: Id

    public let name: String
	public let color: String?
	
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "location_name"
		case color
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
		self.id = try container.decode(Location.Id.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.color = try container.decodeIfPresent(String.self, forKey: .color)
    }
	
    public init(id: String, name: String, color: String? = nil) {
		self.id = Self.Id.init(rawValue: EitherStringOrInt.left(id))
		self.name = name
		self.color = color
	}
}
