import ComposableArchitecture

public protocol ClientsAPI {

    func getClients(search: String?, offset: Int) -> Effect<[Client], RequestError>
    func getItemsCount(clientId: Int) -> Effect<ClientItemsCount, RequestError>

    func getServices() -> Effect<[Service], RequestError>
    func createAppointment(appointment: AppointmentBuilder) -> Effect<PlaceholdeResponse, RequestError>
	func getAppointments(clientId: Int) -> Effect<[Appointment], RequestError>
	func getFinancials(clientId: Int) -> Effect<[Financial], RequestError>
	func getPhotos(clientId: Int) -> Effect<[SavedPhoto], RequestError>
	func getForms(type: FormType, clientId: Int) -> Effect<[FilledFormData], RequestError>
	func getDocuments(clientId: Int) -> Effect<[Document], RequestError>
	func getCommunications(clientId: Int) -> Effect<[Communication], RequestError>
	func getAlerts(clientId: Int) -> Effect<[Alert], RequestError>
	func getNotes(clientId: Int) -> Effect<[Note], RequestError>
	
	func getPatientDetails(clientId: Int) -> Effect<PatientDetails, RequestError>
	func post(patDetails: PatientDetails) -> Effect<PatientDetails, RequestError>
    func addNote(clientId: Int, note: String) -> Effect<Note, RequestError>
    func addAlert(clientId: Int, alert: String) -> Effect<Bool, RequestError>
}
