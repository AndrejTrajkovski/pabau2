import Model

public struct MetaFormAndStatus: Equatable, Identifiable {

//	static let defaultEmpty = MetaFormAndStatus.init(MetaForm.template(FormTemplate.defaultEmpty), false, index: <#Int#>)

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
