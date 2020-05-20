import Model

public struct MetaFormAndStatus: Equatable {

	static let defaultEmpty = MetaFormAndStatus.init(MetaForm.template(FormTemplate.defaultEmpty), false)

	var form: MetaForm
	var isComplete: Bool

	init(_ form: MetaForm, _ isComplete: Bool) {
		self.form = form
		self.isComplete = isComplete
	}
}
