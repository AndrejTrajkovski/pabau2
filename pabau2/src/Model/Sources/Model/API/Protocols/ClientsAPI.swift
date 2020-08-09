import ComposableArchitecture

public protocol ClientsAPI {
	func getClients() -> Effect<Result<[Client], RequestError>, Never>
	func getItemsCount(clientId: Int) -> Effect<Result<ClientItemsCount, RequestError>, Never>
	
	func getAppointments(clientId: Int) -> EffectWithResult<[Appointment], RequestError>
	func getPhotos(clientId: Int) -> Effect<Result<[SavedPhoto], RequestError>, Never>
	func getFinancials(clientId: Int) -> Effect<Result<[Financial], RequestError>, Never>
	func getForms(type: FormType, clientId: Int) -> Effect<Result<[FormData], RequestError>, Never>
	func getDocuments(clientId: Int) -> Effect<Result<[Document], RequestError>, Never>
	func getCommunications(clientId: Int) -> Effect<Result<[Communication], RequestError>, Never>
	func getAlerts(clientId: Int) -> Effect<Result<[Alert], RequestError>, Never>
	func getNotes(clientId: Int) -> Effect<Result<[Note], RequestError>, Never>
	
	func getPatientDetails(clientId: Int) -> Effect<Result<PatientDetails, RequestError>, Never>
}
