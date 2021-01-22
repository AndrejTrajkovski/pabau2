public struct CheckBoxState: Equatable {
	
	public init(_ checkboxes: [String]) {
		self.checkboxes = checkboxes
		self.selected = Set()
	}
	
	public let checkboxes: [String]
	public var selected: Set<String>
	
	public var rows: [CheckBoxChoice] {
		get {
			self.checkboxes.map {
				CheckBoxChoice.init(title: $0, isSelected: selected.contains($0))
			}
		}
		set {
			self.selected = Set(newValue.filter(\.isSelected).map(\.title))
		}
	}
}

public struct CheckBoxChoice: Codable, Hashable, Identifiable {
	public var id: String { title }
	public let title: String
	public var isSelected: Bool
}
