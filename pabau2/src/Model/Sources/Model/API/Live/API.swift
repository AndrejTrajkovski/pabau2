import Foundation
import ComposableArchitecture
import Combine

public class APIClient: LoginAPI {
	public init(baseUrl: String, loggedInUser: User?) {
		self.baseUrl = baseUrl
		self.loggedInUser = loggedInUser
	}
	
	private(set) var baseUrl: String = "https://crm.pabau.com"
	private var loggedInUser: User? = nil
    let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
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
	
	func commonAnd(other: [String: Any]) -> [String: Any] {
		commonParams().merging(other, uniquingKeysWith: { old, new in return new })
	}
	
	func getUserParams() -> [String: Any]? {
		loggedInUser.map {
			[
				"company": $0.apiKey,
				"user_id": $0.userID.rawValue,
				"api_key": $0.apiKey,
			]
		}
	}
	
	func commonParams() -> [String: Any] {
		let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		let userParams = getUserParams() ?? [:]
		let versionParams = ["app_version" : version ?? ""] as [String: Any]
		return versionParams.merging(userParams, uniquingKeysWith: { old, new in return old })
	}
}
