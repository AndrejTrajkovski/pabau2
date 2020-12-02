public struct RadioState: Codable, Equatable, Hashable {
	public var choices: [RadioChoice]
	public var selectedChoiceId: Int

	public init (_ id: Int, _ choices: [RadioChoice], _ selectedChoiceId: Int) {
		self.choices = choices
		self.selectedChoiceId = selectedChoiceId
	}
}

public struct RadioChoice: Codable, Equatable, Hashable {
	public let id: Int
	public let title: String

	public init (_ id: Int, _ title: String) {
		self.id = id
		self.title = title
	}
}
