public struct CheckBoxState: Equatable {
	
	public init(_ checkboxes: [CheckBoxChoice]) {
		self.checkboxes = checkboxes
		self.selected = []
	}
	
	let checkboxes: [CheckBoxChoice]
	var selected: [CheckBoxChoice]
}

public struct CheckBoxChoice: Codable, Equatable, Identifiable {
	public var id: String { title }
	public let title: String
}
