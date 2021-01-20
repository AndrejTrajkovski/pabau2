import ComposableArchitecture

public protocol FormAPI {
	func get(form: HTMLForm.ID) -> Effect<Result<HTMLForm, RequestError>, Never>
	func post(form: HTMLForm, appointments: [CalendarEvent.Id]) -> Effect<Result<HTMLForm, RequestError>, Never>	
	func getTemplates(_ type: FormType) -> Effect<Result<[HTMLForm], RequestError>, Never>
}
