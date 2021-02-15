import Tagged
import Foundation

public struct Service: Codable, Identifiable, Equatable, Hashable {

	public typealias Id = Tagged<Service, String>
	
    public let id: Id

    public let name: String

    public let color: String?

    public let categoryName: String?

    public let disabledUsers: String?

    public let duration: String?

    public init(
        id: String,
        name: String,
        color: String,
        categoryName: String,
        disabledUsers: String? = nil,
        duration: String? = nil
    ) {
        self.id = Service.Id.init(rawValue: id)
        self.name = name
        self.color = color
        self.categoryName = categoryName
        self.disabledUsers = disabledUsers
        self.duration = duration
    }
	
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "service_name"
        case color = "service_color"
        case categoryName = "category_name"
        case disabledUsers = "disabledusers"
        case duration
    }

}
