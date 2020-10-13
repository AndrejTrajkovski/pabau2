import Foundation
import Tagged

public struct Room: Codable, Identifiable, Equatable {
	
	public typealias Id = Tagged<Room, Int>
	
    public let id: Id

    public let name: String
	
	public let locationId: Location.Id
	
	public init(id: Int, name: String, locationId: Location.Id) {
		self.id = Id(rawValue: id)
        self.name = name
		self.locationId = locationId
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
		case locationId
    }

}

extension Room {
	
	public static func mock() -> [Room.Id: Room] {
		[
			Room.Id(0): Room(id: 0, name: "Botox room", locationId: Location.randomId()),
			Room.Id(1): Room(id: 1, name: "Bathroom", locationId: Location.randomId()),
			Room.Id(2): Room(id: 2, name: "Hot box room", locationId: Location.randomId()),
			Room.Id(3): Room(id: 3, name: "Bedroom", locationId: Location.randomId()),
			Room.Id(4): Room(id: 4, name: "Red room", locationId: Location.randomId()),
			Room.Id(5): Room(id: 5, name: "Boiler room", locationId: Location.randomId())
		]
	}
}
