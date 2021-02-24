public struct StepFormInfo: Equatable {
	public init(status: Bool, title: String) {
		self.status = status
		self.title = title
	}
	
	public let status: Bool
	public let title: String
}
