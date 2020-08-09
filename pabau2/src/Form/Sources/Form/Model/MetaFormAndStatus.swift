import Model

public struct MetaFormAndStatus: Equatable {

	static let defaultEmpty = MetaFormAndStatus.init(MetaForm.template(FormTemplate.defaultEmpty), false)

	public var form: MetaForm
	public var isComplete: Bool

	public init(_ form: MetaForm, _ isComplete: Bool) {
		self.form = form
		self.isComplete = isComplete
	}
}
