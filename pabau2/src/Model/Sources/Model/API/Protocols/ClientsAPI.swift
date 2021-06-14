import ComposableArchitecture

public protocol ClientsAPI {

	func getClients(search: String?, offset: Int) -> Effect<[Client], RequestError>
	func getItemsCount(clientId: Client.Id) -> Effect<ClientItemsCount, RequestError>
	
	func getServices() -> Effect<[Service], RequestError>
	func createAppointment(appointment: AppointmentBuilder) -> Effect<Appointment, RequestError>
	func updateAppointment(appointment: AppointmentBuilder) -> Effect<PlaceholdeResponse, RequestError>
    
	func getAppointments(clientId: Client.Id) -> Effect<[CCAppointment], RequestError>
    func getAppointmentStatus() -> Effect<[AppointmentStatus], RequestError>
    func appointmentChangeStatus(appointmentId: Appointment.ID, status: String) -> Effect<Bool, RequestError>
    func appointmentChangeCancelReason(appointmentId: Appointment.ID, reason: String) -> Effect<Bool, RequestError>
    func getAppointmentCancelReasons() -> Effect<[CancelReason], RequestError>
    func createRecurringAppointment(appointmentId: Appointment.ID, repeatRange: String, repeatUntil: String) -> Effect<Bool, RequestError>
    
    func getBookoutReasons() -> Effect<[BookoutReason], RequestError>
	func getFinancials(clientId: Client.Id) -> Effect<[Financial], RequestError>
	func getPhotos(clientId: Client.Id) -> Effect<[SavedPhoto], RequestError>
	func getForms(type: FormType, clientId: Client.Id) -> Effect<[FilledFormData], RequestError>
	func getDocuments(clientId: Client.Id) -> Effect<[Document], RequestError>
	func getCommunications(clientId: Client.Id) -> Effect<[Communication], RequestError>
	func getAlerts(clientId: Client.Id) -> Effect<[Alert], RequestError>
	func getNotes(clientId: Client.Id) -> Effect<[Note], RequestError>
	
	func update(clientBuilder: ClientBuilder) -> Effect<Client.ID, RequestError>
	func addNote(clientId: Client.Id, note: String) -> Effect<Note, RequestError>
	func addAlert(clientId: Client.Id, alert: String) -> Effect<Bool, RequestError>
}
