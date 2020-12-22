//
// Service.swift

import Foundation

public struct Service: Codable, Identifiable, Equatable, Hashable {

    public let id: Int

    public let name: String

    public let color: String

    public let categoryId: Int

    public let categoryName: String

    public let disabledUsers: [Int]?

    public let duration: String?
    
    public init(
        id: Int,
        name: String,
        color: String,
        categoryId: Int,
        categoryName: String,
        disabledUsers: [Int]? = nil,
        duration: String? = nil
    ) {
        self.id = id
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
        case categoryId = "category_id"
        case categoryName = "category_name"
        case disabledUsers = "disabled_users"
        case duration
    }

}
