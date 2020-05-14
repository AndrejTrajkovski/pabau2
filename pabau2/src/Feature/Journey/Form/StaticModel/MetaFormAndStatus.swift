import Model

public struct MetaFormAndStatus: Equatable, Hashable, CustomDebugStringConvertible {
	
	public var debugDescription: String {
		return form.debugDescription
	}
	
	static let defaultEmpty = MetaFormAndStatus.init(MetaForm.template(FormTemplate.defaultEmpty), false)

	var form: MetaForm
	var isComplete: Bool

	init(_ form: MetaForm, _ isComplete: Bool) {
		self.form = form
		self.isComplete = isComplete
	}
}
