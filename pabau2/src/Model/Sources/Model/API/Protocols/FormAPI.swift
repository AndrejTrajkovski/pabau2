import ComposableArchitecture

public protocol FormAPI {
	func getForm(templateId: FormTemplateInfo.ID) -> Effect<HTMLForm, RequestError>
	func getForm(templateId: FormTemplateInfo.ID, entryId: FilledFormData.ID) -> Effect<HTMLForm, RequestError>
	func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<HTMLForm, RequestError>
	func getTemplates(_ type: FormType) -> Effect<[FormTemplateInfo], RequestError>
}
