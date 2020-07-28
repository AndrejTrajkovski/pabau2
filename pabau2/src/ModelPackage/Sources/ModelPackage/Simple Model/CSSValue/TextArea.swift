public struct TextArea: Codable, Equatable, Hashable {
	public init (text: String) { self.text = text }
	public var text: String
}
