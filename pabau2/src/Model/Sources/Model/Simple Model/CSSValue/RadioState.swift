public struct RadioState: Codable, Equatable {
	public let choices: [RadioChoice]
	public var selectedChoiceId: RadioChoice.ID?

	public init (_ choices: [RadioChoice], _ selectedChoiceId: RadioChoice.ID? = nil) {
		self.choices = choices
		self.selectedChoiceId = selectedChoiceId
	}
}

public struct RadioChoice: Codable, Equatable, Identifiable {
	public let title: String
	public var id: String { title }
	
	public init (_ title: String) {
		self.title = title
	}
}
