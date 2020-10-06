import Foundation
import Tagged

public struct Location: Codable, Identifiable, Equatable {

	public typealias Id = Tagged<Location, Int>
	
    public let id: Id

    public let name: String?
    public init(id: Int, name: String? = nil) {
		self.id = Id(rawValue: id)
        self.name = name
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
    }

}
