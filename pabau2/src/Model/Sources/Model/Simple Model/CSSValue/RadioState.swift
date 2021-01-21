public struct RadioState: Codable, Equatable {
	public let choices: [RadioChoice]
	public var selectedChoice: RadioChoice? = nil

	public init (_ choices: [RadioChoice]) {
		self.choices = choices
	}
}

public struct RadioChoice: Codable, Equatable, Identifiable {
	public let title: String
	public var id: String { title }
	
	public init (_ title: String) {
		self.title = title
	}
}
