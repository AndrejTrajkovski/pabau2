import Foundation
import Tagged

public typealias EitherStringOrInt = Either<String, Int>

extension EitherStringOrInt: CustomStringConvertible {
	public var description: String {
		switch self {
		case .left(let string):
			return string
		case .right(let int):
			return String(int) 
		}
	}
}

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
	
	public init(id: String, name: String) {
		self.id = Self.Id.init(rawValue: EitherStringOrInt.left(id))
		self.name = name
		self.color = nil
	}
}
