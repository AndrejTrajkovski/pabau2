import ComposableArchitecture
import SwiftDate

public struct ClientsMockAPI: MockAPI, ClientsAPI {
	public func getPatientDetails(clientId: Int) -> Effect<PatientDetails, RequestError> {
		mockSuccess(PatientDetails.mock(clientId: clientId))
	}
	
    public func getClients(search: String? = nil, offset: Int = 0) -> Effect<[Client], RequestError> {
		mockSuccess(Client.mockClients, delay: 0.2)
	}
	
	public func getItemsCount(clientId: Int) -> Effect<ClientItemsCount, RequestError> {
		mockSuccess(ClientItemsCount.init(id: 1, appointments: 2, photos: 4, financials: 6, treatmentNotes: 3, presriptions: 10, documents: 15, communications: 123, consents: 4381, alerts: 123, notes: 0))
	}
	
	public func getAppointments(clientId: Int) -> Effect<[Appointment], RequestError> {
		mockSuccess(Appointment.mockAppointments, delay: 1.0)
	}
	
	public func getPhotos(clientId: Int) -> Effect<[SavedPhoto], RequestError> {
		mockSuccess(SavedPhoto.mockCC)
	}
	public func getFinancials(clientId: Int) -> Effect<[Financial], RequestError> {
		mockSuccess(Financial.mockFinancials)
	}
	public func getForms(type: FormType, clientId: Int) -> Effect<[FormData], RequestError> {
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
	
	public func getDocuments(clientId: Int) -> Effect<[Document], RequestError> {
		mockSuccess(Document.mockDocs, delay: 0.2)
	}
	
	public func getCommunications(clientId: Int) -> Effect<[Communication], RequestError> {
		mockSuccess(Communication.mockComm)
	}
	
	public func getAlerts(clientId: Int) -> Effect<[Alert], RequestError> {
		mockSuccess(Alert.mockAlerts)
	}
	
	public func getNotes(clientId: Int) -> Effect<[Note], RequestError> {
		mockSuccess(Note.mockNotes)
	}
	
	public func post(patDetails: PatientDetails) -> Effect<PatientDetails, RequestError> {
		return mockSuccess(patDetails)
	}
	
	public init () {}
}
