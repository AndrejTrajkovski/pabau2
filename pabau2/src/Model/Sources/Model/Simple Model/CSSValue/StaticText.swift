public struct StaticText: Codable, Equatable, Hashable {
	public let text: String
	public init( _ id: Int, _ text: String) {
		self.text = text
	}
}
