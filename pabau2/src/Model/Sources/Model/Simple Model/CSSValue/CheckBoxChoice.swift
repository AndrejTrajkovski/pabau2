public struct CheckBoxState: Equatable {
	
	public init(_ checkboxes: [String],
				_ parentId: CSSFieldID) {
		self.checkboxes = checkboxes
		self.selected = Set()
		self.parentId = parentId
	}
	
	public let parentId: CSSFieldID
	public let checkboxes: [String]
	public var selected: Set<String>
	
	public var rows: [CheckBoxChoice] {
		get {
			zip(self.checkboxes, self.checkboxes.indices).map {
				CheckBoxChoice.init(index: $0.1, parentId: parentId, title: $0.0, isSelected: selected.contains($0.0))
			}
		}
		set {
			self.selected = Set(newValue.filter(\.isSelected).map(\.title))
		}
	}
}

public struct CheckBoxChoice: Identifiable, Equatable {
	public var id: String {
		parentId.fakeId.rawValue + title + String(index)
	}
	
	let index: Int
	let parentId: CSSFieldID
	public let title: String
	public var isSelected: Bool
}
