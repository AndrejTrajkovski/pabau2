public struct StepEntry: Decodable, Equatable {
	public let status: StepStatus
	public let formTemplateId: FormTemplateInfo.ID?
	public let formEntryId: FilledFormData.ID?
}
