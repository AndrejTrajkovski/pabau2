public struct Select: Codable, Equatable {
	public init(_ id: Int,
							_ choices: [SelectChoice],
							_ selectedChoiceId: Int? = nil) {
		self.id = id
		self.choices = choices
		self.selectedChoiceId = selectedChoiceId
	}
	
	public let id: Int
	public let choices: [SelectChoice]
	public var selectedChoiceId: Int?
}

public struct SelectChoice: Codable, Hashable {
	public init(_ id: Int, _ title: String) {
		self.id = id
		self.title = title
	}
	
	public let id: Int
	public let title: String
}
