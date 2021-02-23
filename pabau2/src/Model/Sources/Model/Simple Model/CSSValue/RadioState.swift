public struct RadioState: Equatable {
	public let parentId: CSSFieldID
	public let choices: [RadioChoice]
	public var selectedChoice: RadioChoice? = nil
	
	public init (_ choices: [RadioChoice],
				 _ parentId: CSSFieldID) {
		self.choices = choices
		self.parentId = parentId
	}
}

public struct RadioChoice: Hashable {
	public let title: String
	public let parentId: CSSFieldID
	
	public init (_ title: String,
				 _ parentId: CSSFieldID) {
		self.title = title
		self.parentId = parentId
	}
}
