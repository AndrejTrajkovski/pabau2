import Foundation

public struct PathwayTemplate: Codable, Identifiable, Equatable {

    public let id: Int

    public let title: String

    public let steps: [Step]

    public let _description: String?
    public init(id: Int, title: String, steps: [Step], _description: String? = nil) {
        self.id = id
        self.title = title
        self.steps = steps
        self._description = _description
    }
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case title
        case steps
        case _description = "description"
    }

}
