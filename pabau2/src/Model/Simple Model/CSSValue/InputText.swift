public struct InputText: Codable, Equatable, Hashable {
	public init (text: String) { self.text = text }
	public var text: String
}
