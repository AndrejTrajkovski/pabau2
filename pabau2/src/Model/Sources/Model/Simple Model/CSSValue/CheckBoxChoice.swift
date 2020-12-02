public struct CheckBoxChoice: Codable, Equatable, Hashable, Identifiable {
	public init( _ id: Int, _ title: String, _ isSelected: Bool) {
		self.id = id
		self.title = title
		self.isSelected = isSelected
	}

	public var id: Int
	public var title: String
	public var isSelected: Bool
}
