public struct SelectState: Codable, Equatable {
	public init(_ choices: [SelectChoice]) {
		self.choices = choices
	}
	public let choices: [SelectChoice]
	public var selectedChoice: SelectChoice?
}

public struct SelectChoice: Codable, Hashable {
	public init(_ title: String) {
		self.title = title
	}
	
	public let title: String
}
