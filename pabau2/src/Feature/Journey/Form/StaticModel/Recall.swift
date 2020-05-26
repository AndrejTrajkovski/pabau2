public struct Recall: Equatable {
	let title: String
	var isSelected: Bool

	public init (_ title: String, _ isSelected: Bool = false) {
		self.title = title
		self.isSelected = isSelected
	}
}
