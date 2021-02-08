import ComposableArchitecture
import Combine

public class APIClient: LoginAPI, JourneyAPI, ClientsAPI {
	public init(baseUrl: String, loggedInUser: User?) {
		self.baseUrl = baseUrl
		self.loggedInUser = loggedInUser
	}
	
	var baseUrl: String = "https://crm.pabau.com"
	var loggedInUser: User? = nil
	let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}

//MARK: - LoginAPI: ClientApi
extension APIClient {
	public func getClients() -> Effect<[Client], RequestError> {
        let requestBuilder: RequestBuilder<ClientResponse>.Type = requestBuilderFactory.getBuilder()
		struct ClientResponse: Codable, Equatable {
			public let clients: [Client]
			public enum CodingKeys: String, CodingKey {
				case clients = "appointments"
			}
		}
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: commonAnd(other: [:]),
                                   isBody: false)
            .effect()
            .map(\.clients)
            .eraseToEffect()
	}
	
	public func getItemsCount(clientId: Int) -> Effect<ClientItemsCount, RequestError> {
        Just(ClientItemsCount.init(id: 1, appointments: 2, photos: 4, financials: 6, treatmentNotes: 3, presriptions: 10, documents: 15, communications: 123, consents: 4381, alerts: 123, notes: 0))
            .mapError { _ in RequestError.emptyDataResponse }
            .eraseToEffect()
	}
	
	public func getAppointments(clientId: Int) -> Effect<[Appointment], RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func getPhotos(clientId: Int) -> Effect<[SavedPhoto], RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func getFinancials(clientId: Int) -> Effect<[Financial], RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func getForms(type: FormType, clientId: Int) -> Effect<[FormData], RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func getDocuments(clientId: Int) -> Effect<[Document], RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func getCommunications(clientId: Int) -> Effect<[Communication], RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func getAlerts(clientId: Int) -> Effect<[Alert], RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func getNotes(clientId: Int) -> Effect<[Note], RequestError> {
        let requestBuilder: RequestBuilder<NoteResponse>.Type = requestBuilderFactory.getBuilder()
		struct NoteResponse: Codable {
			public let notes: [Note]
			public enum CodingKeys: String, CodingKey {
				case notes = "employees"
			}
		}
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClientsNotes,
                                   queryParams: commonAnd(other: [
                                                            "contact_id": "\(clientId)"
                                   ]),
                                   isBody: false)
            .effect()
            .map(\.notes)
            .eraseToEffect()
	}
	
	public func getPatientDetails(clientId: Int) -> Effect<PatientDetails, RequestError> {
		fatalError("TODO Cristian")
	}
	
	public func post(patDetails: PatientDetails) -> Effect<PatientDetails, RequestError> {
		fatalError("TODO Cristian")
	}
}
