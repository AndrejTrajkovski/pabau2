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
    
    public init(id: Id, name: String, locationIds: [Location.Id]) {
        self.id = id
        self.name = name
        self.locationIds = locationIds
    }
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: Self.CodingKeys)
        let parseId = try container.decode(EitherStringOrInt.self, forKey: .id)
        self.id = Self.ID.init(rawValue: parseId.description)
		self.name = try container.decode(String.self, forKey: .room_name)
		if let roomLocations: [[String: String]] = try? container.decode([[String:String]].self, forKey: .room_locations) {
			self.locationIds = roomLocations.reduce(into: [Location.Id](), { acc, element in
				if let locIdString = element["location_id"] {
					let locId = Location.ID.init(rawValue: Int(locIdString)!)
					acc.append(locId)
				}
			})
		}else {
			self.locationIds = []
		}
	}
}
