import ComposableArchitecture

public protocol FormAPI {
	func get(form: HTMLFormTemplate.ID) -> Effect<Result<HTMLFormTemplate, RequestError>, Never>
	func post(form: HTMLFormTemplate, appointments: [CalendarEvent.Id]) -> Effect<Result<HTMLFormTemplate, RequestError>, Never>	
	func getTemplates(_ type: FormType) -> Effect<Result<[HTMLFormTemplate], RequestError>, Never>
}
