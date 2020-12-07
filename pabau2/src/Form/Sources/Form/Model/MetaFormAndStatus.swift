import Model

public struct MetaFormAndStatus: Equatable, Identifiable {
	public var id: Int { index }

	public var index: Int
	public var form: MetaForm
	public var isComplete: Bool

	public init(_ form: MetaForm,
				_ isComplete: Bool,
				index: Int) {
		self.form = form
		self.isComplete = isComplete
		self.index = index
	}
}
