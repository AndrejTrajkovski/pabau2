public struct FormStepEntry: Decodable, Equatable {
	let status: StepStatus
	let formTemplateId: FormTemplateInfo.ID?
	let formEntryId: FilledFormData.ID?
}
