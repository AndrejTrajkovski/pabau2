import ComposableArchitecture

public protocol FormAPI {
	func getTemplate(id: HTMLForm.ID) -> Effect<HTMLForm, RequestError>
	func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<HTMLForm, RequestError>
	func getTemplates(_ type: FormType) -> Effect<[HTMLFormInfo], RequestError>
}
