import Foundation
import ComposableArchitecture
import Combine

public class APIClient: LoginAPI, JourneyAPI {
	
	public init(baseUrl: String, loggedInUser: User?) {
		self.baseUrl = baseUrl
		self.loggedInUser = loggedInUser
	}
	
	private var baseUrl: String = "https://crm.pabau.com"
	private var loggedInUser: User? = nil
	private let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
}

public enum APIPath: String {
	//Login
	case sendConfirmation
	case login = "/OAuth2/staff/login-check.php"
	case resetPass = "reset"
	//Journey
	case getJourneys
	//Calendar
	
	//Contacts/ Clients
	
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
				"company": $0.apiKey,
				"user_id": $0.userID.rawValue,
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
