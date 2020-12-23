public struct CheckBoxChoice: Codable, Equatable, Identifiable {
	
	public init(_ title: String) {
		self.title = title
	}

	public var id: String { title }
	public let title: String
	public var isSelected: Bool = false
}
