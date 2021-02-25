import Foundation
import Tagged

public struct Room: Decodable, Identifiable, Equatable {
	
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
