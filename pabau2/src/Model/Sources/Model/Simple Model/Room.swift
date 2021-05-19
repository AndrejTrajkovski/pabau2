import Foundation
import Tagged

public struct Room: Decodable, Identifiable, Equatable {
	
	public typealias Id = Tagged<Room, Int>
	
    public let id: Id

    public let name: String
	
	public let locationIds: [Location.Id]
	
	public init(id: Int, name: String, locationIds: [Location.Id]) {
		self.id = Id(rawValue: id)
        self.name = name
		self.locationIds = locationIds
    }
	
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
		case locationIds
    }

}
