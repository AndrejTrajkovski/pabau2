import Model

public protocol MetaFormAndStatus: MetaForm {
	var index: Int { get set }
	var isComplete: Bool { get set }
}
