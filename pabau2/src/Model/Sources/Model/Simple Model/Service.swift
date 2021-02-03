import Tagged
import Foundation

public struct Service: Codable, Identifiable, Equatable, Hashable {

	public typealias Id = Tagged<Service, Int>
	
    public let id: Id

    public let name: String

    public let color: String

    public let categoryId: Int

    public let categoryName: String

    public let disabledUsers: [Int]?

    public let duration: String?
	
    public init(id: Int, name: String, color: String, categoryId: Int, categoryName: String, disabledUsers: [Int]? = nil, duration: String? = nil) {
		self.id = Service.Id.init(rawValue: id)
        self.name = name
        self.color = color
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.disabledUsers = disabledUsers
        self.duration = duration
    }
	
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case color
        case categoryId = "categoryid"
        case categoryName = "category_name"
        case disabledUsers = "disabled_users"
        case duration
    }

}
