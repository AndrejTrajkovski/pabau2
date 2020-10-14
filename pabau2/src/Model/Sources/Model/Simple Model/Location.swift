import Foundation
import Tagged

public struct Location: Codable, Identifiable, Equatable {

	public typealias Id = Tagged<Location, Int>
	
    public let id: Id

    public let name: String
	public let color: String
	
	public init(id: Int,
				name: String,
				color: String) {
		self.id = Id(rawValue: id)
		self.name = name
		self.color = color
	}
	
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
		case color
    }

}

extension Location {
	
	public static func randomId() -> Location.Id {
		mock().randomElement()!.key
	}
	
	public static func mock() -> [Location.Id: Location] {
		[
			Location.Id(1): Location(id: 1, name: "Leicester", color: "#FF0000"),
			Location.Id(2): Location(id: 2, name: "London", color: "#FF00FF"),
			Location.Id(3): Location(id: 3, name: "Aston Villa", color: "#800080"),
			Location.Id(4): Location(id: 4, name: "Everton", color: "#00FF00"),
			Location.Id(5): Location(id: 5, name: "Portsmouth", color: "#FFB6C1"),
			Location.Id(6): Location(id: 6, name: "Skopje", color: "#FFFF00"),
			Location.Id(7): Location(id: 7, name: "Shuto Orizari", color: "#9932CC")
		]
	}
}

