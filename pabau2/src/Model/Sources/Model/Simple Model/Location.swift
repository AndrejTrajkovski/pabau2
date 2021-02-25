import Foundation
import Tagged

public typealias EitherStringOrInt = Either<String, Int>

public enum Either<Left: Decodable & Equatable & Hashable, Right: Decodable & Equatable & Hashable>: Decodable, Equatable, Hashable {
	case left(Left)
	case right(Right)
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let leftValue = try? container.decode(Left.self) {
			self = .left(leftValue)
		} else if let rightValue = try? container.decode(Right.self) {
			self = .right(rightValue)
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not decode either type")
		}
	}
}

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

}

extension Location {
	
	public static func randomId() -> Location.Id {
		mock().randomElement()!.id
	}
	
	public static func mock() -> [Location] {
		[
			Location(id: 1, name: "Leicester", color: "#FF0000"),
			Location(id: 2, name: "London", color: "#FF00FF"),
			Location(id: 3, name: "Birmingham", color: "#800080"),
			Location(id: 4, name: "Manchester", color: "#00FF00"),
			Location(id: 5, name: "Portsmouth", color: "#FFB6C1"),
			Location(id: 6, name: "Skopje", color: "#FFFF00"),
			Location(id: 7, name: "Liverpool", color: "#9932CC")
		]
	}
}

