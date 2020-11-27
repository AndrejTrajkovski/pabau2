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

