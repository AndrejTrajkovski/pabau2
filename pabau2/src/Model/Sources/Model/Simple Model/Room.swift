import Foundation
import Tagged

public struct Room: Decodable, Identifiable, Equatable {
	
	public typealias Id = Tagged<Room, String>
	
	public let id: Id
	
	public let name: String
	
	public let locationIds: [Location.Id]
	
	public enum CodingKeys: String, CodingKey {
		case id = "id"
		case room_name
		case room_locations
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
		self.id = try container.decode(Id.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .room_name)
		if let roomLocations: [[String: String]] = try? container.decode([[String:String]].self, forKey: .room_locations) {
			self.locationIds = roomLocations.reduce(into: [Location.Id](), { acc, element in
				if let locIdString = element["location_id"] {
					let locId = Location.ID.init(rawValue: .left(locIdString))
					acc.append(locId)
				}
			})
		}else {
			self.locationIds = []
		}
	}
}
