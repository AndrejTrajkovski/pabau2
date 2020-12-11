import Model

//public protocol MetaFormAndStatus {
//	var form: MetaForm { get set }
//	var isComplete: Bool { get set }
//}

public struct MetaFormAndStatus {
	public var form: MetaForm
	public var isComplete: Bool
	
	public init(_ form: MetaForm, _ isComplete: Bool) {
		self.form = form
		self.isComplete = isComplete
	}
}
