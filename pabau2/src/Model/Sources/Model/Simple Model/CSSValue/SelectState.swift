import ComposableArchitecture

public struct SelectState: Equatable {
	public init(_ choices: [String], _ fieldId: CSSFieldID) {
		self.choices = choices.map { SelectChoice($0, fieldId) }
//		self.fieldId = fieldId
	}
//	private let fieldId: CSSFieldID
	public let choices: [SelectChoice]
	public var selectedChoice: SelectChoice?
	
	public mutating func select(choice: String) {
		self.selectedChoice = choices.first(where: { $0.title == choice })
	}
}

public struct SelectChoice: Hashable {
	fileprivate init(_ title: String, _ parentId: CSSFieldID) {
		self.title = title
		self.parentId = parentId
	}
	
	private let parentId: CSSFieldID
	public let title: String
}
