import ComposableArchitecture
import SwiftDate

public struct ClientsMockAPI: MockAPI, ClientsAPI {
	public func getPatientDetails(clientId: Int) -> Effect<Result<PatientDetails, RequestError>, Never> {
		mockSuccess(PatientDetails.mock(clientId: clientId))
	}
	
    public func getClients(search: String? = nil, offset: Int = 0) -> Effect<Result<[Client], RequestError>, Never> {
		mockSuccess(Client.mockClients, delay: 0.2)
	}
	
	public func getItemsCount(clientId: Int) -> Effect<Result<ClientItemsCount, RequestError>, Never> {
		mockSuccess(ClientItemsCount.init(id: 1, appointments: 2, photos: 4, financials: 6, treatmentNotes: 3, presriptions: 10, documents: 15, communications: 123, consents: 4381, alerts: 123, notes: 0))
	}
	
	public func getAppointments(clientId: Int) -> Effect<Result<[Appointment], RequestError>, Never> {
		mockSuccess(Appointment.mockAppointments, delay: 1.0)
	}
	
	public func getPhotos(clientId: Int) -> Effect<Result<[SavedPhoto], RequestError>, Never> {
		mockSuccess(SavedPhoto.mockCC)
	}
	public func getFinancials(clientId: Int) -> Effect<Result<[Financial], RequestError>, Never> {
		mockSuccess(Financial.mockFinancials)
	}
	public func getForms(type: FormType, clientId: Int) -> Effect<Result<[FormData], RequestError>, Never> {
		switch type {
		case .consent:
			return mockSuccess(FormData.mockFilledConsents)
		case .prescription:
			return mockSuccess(FormData.mockFIlledPrescriptions)
		case .treatment:
			return mockSuccess(FormData.mockFilledTreatments)
		case .history:
			fatalError()
		}
	}
	public func getDocuments(clientId: Int) -> Effect<Result<[Document], RequestError>, Never> {
		mockSuccess(Document.mockDocs, delay: 0.2)
	}
	public func getCommunications(clientId: Int) -> Effect<Result<[Communication], RequestError>, Never> {
		mockSuccess(Communication.mockComm)
	}
	public func getAlerts(clientId: Int) -> Effect<Result<[Alert], RequestError>, Never> {
		mockSuccess(Alert.mockAlerts)
	}
	
	public func getNotes(clientId: Int) -> Effect<Result<[Note], RequestError>, Never> {
		mockSuccess(Note.mockNotes)
	}
	
	public func post(patDetails: PatientDetails) -> Effect<Result<PatientDetails, RequestError>, Never> {
		return mockSuccess(patDetails)
	}
	
	public init () {}
}
