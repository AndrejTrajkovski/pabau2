import Model

public struct StepFormInfo: Equatable {
	public init(status: StepStatus, title: String) {
		self.status = status
		self.title = title
	}

	public let status: StepStatus
	public let title: String
}
