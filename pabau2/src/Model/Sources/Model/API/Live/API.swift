import Foundation
import ComposableArchitecture
import Combine

public class APIClient: LoginAPI, JourneyAPI, ClientsAPI {
	public init(baseUrl: String, loggedInUser: User?) {
		self.baseUrl = baseUrl
		self.loggedInUser = loggedInUser
	}
	
	private var baseUrl: String = "https://crm.pabau.com"
	private var loggedInUser: User? = nil
	private let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}

//MARK: - LoginAPI
extension APIClient {
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError> {
		let requestBuilder: RequestBuilder<ResetPassSuccess>.Type = requestBuilderFactory.getBuilder()
		let res = requestBuilder.init(method: .GET,
									  baseUrl: baseUrl,
									  path: .sendConfirmation,
									  queryParams: [:],
									  isBody: false)
		return res.publisher().eraseToEffect()
	}
	
	public func updateLoggedIn(user: User) {
		self.loggedInUser = user
	}
	
	public func login(_ username: String, password: String) -> Effect<LoginResponse, LoginError> {
		let requestBuilder: RequestBuilder<LoginResponse>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .login,
								   queryParams: ["username": username,
												 "password": password],
								   isBody: false)
			.effect()
			.validate()
			.mapError { LoginError.requestError($0) }
			.eraseToEffect()
	}
	
	public func resetPass(_ email: String) -> Effect<ForgotPassSuccess, RequestError> {
		let requestBuilder: RequestBuilder<ForgotPassSuccess>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .resetPass,
								   queryParams: ["email": email],
								   isBody: false)
			.effect()
	}
	
	func commonAnd(other: [String: String]) -> [String: String] {
		commonParams().merging(other, uniquingKeysWith: { old, new in return new })
	}
	
	func getUserParams() -> [String: String]? {
		loggedInUser.map {
			[
				"user_id": "\($0.userID)",
				"company": $0.companyID,
				"api_key": $0.apiKey,
			]
		}
	}
	
	func commonParams() -> [String: String] {
		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		let userParams = getUserParams() ?? [:]
		let versionParams = ["app_version" : version ?? ""]
		return versionParams.merging(userParams, uniquingKeysWith: { old, new in return old })
	}
}

//MARK: - JourneyAPI
extension APIClient {
	
	public func getJourneys(date: Date, searchTerm: String?) -> Effect<[Journey], RequestError> {
		let requestBuilder: RequestBuilder<[Journey]>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .getJourneys,
								   queryParams: commonAnd(other: [:]),
								   isBody: false)
			.effect()
	}
	
	public func getEmployees(companyId: Company.ID) -> Effect<[Employee], RequestError> {
		fatalError()
	}
	
	public func getTemplates(_ type: FormType) -> Effect<[FormTemplate], RequestError> {
		fatalError()
	}
}

//MARK: - LoginAPI: ClientApi
extension APIClient {
	public func getClients() -> Effect<[Client], RequestError> {
        let requestBuilder: RequestBuilder<ClientResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getClients,
                                   queryParams: commonAnd(other: [:]),
                                   isBody: false)
            .effect()
            .validate()
            .mapError { $0 }
            .map { $0.clients }
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
        let requestBuilder: RequestBuilder<FinancialResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getFinancials,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]),
                                   isBody: false)
            .effect()
            .validate()
            .mapError { $0 }
            .map { $0.sales }
            .eraseToEffect()

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
		fatalError("TODO Cristian")
	}
	
	public func getPatientDetails(clientId: Int) -> Effect<PatientDetails, RequestError> {
        let requestBuilder: RequestBuilder<PatientDetailsResponse>.Type = requestBuilderFactory.getBuilder()
        return requestBuilder.init(method: .GET,
                                   baseUrl: baseUrl,
                                   path: .getPatientDetails,
                                   queryParams: commonAnd(other: ["contact_id": "\(clientId)"]),
                                   isBody: false)
            .effect()
            .validate()
            .mapError { $0 }
            .map { $0.details?.first ?? PatientDetails.emptyMock }
            .eraseToEffect()
	}
	
	public func post(patDetails: PatientDetails) -> Effect<PatientDetails, RequestError> {
		fatalError("TODO Cristian")
	}
}
