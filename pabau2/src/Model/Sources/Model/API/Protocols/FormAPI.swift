import ComposableArchitecture

public protocol FormAPI {
	func get(form: FormTemplate.ID) -> Effect<Result<FormTemplate, RequestError>, Never>
	func post(form: FormTemplate, appointments: [Appointment.Id]) -> Effect<Result<FormTemplate, RequestError>, Never>	
	func getTemplates(_ type: FormType) -> Effect<Result<[FormTemplate], RequestError>, Never>
}
