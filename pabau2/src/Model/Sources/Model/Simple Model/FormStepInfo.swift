public struct FormStepInfo: Decodable {
	let status: StepStatus
	let formTemplateId: FormTemplateInfo.ID?
	let formEntryId: FilledFormData.ID?
}
