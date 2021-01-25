import Foundation
import ComposableArchitecture

public struct APIClient: LoginAPI {
	public init () {}
	
	var baseUrl: String = "https://crm.pabau.com"
	var loggedInUser: User?
	public var requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError> {
		let requestBuilder: RequestBuilder<ResetPassSuccess>.Type = requestBuilderFactory.getBuilder()
		let res = requestBuilder.init(method: "GET", URLString: "", parameters: [:], isBody: false)
		return res.publisher().eraseToEffect()
	}
	
	public func login(_ username: String, password: String) -> Effect<LoginResponse, LoginError> {
		let path = "/OAuth2/staff/login-check.php"
		let URLString = baseUrl + path
		var url = URLComponents(string: URLString)
		let queryItems: [String: Any] = ["username": username, "password": password]
		url?.queryItems = APIHelper.mapValuesToQueryItems(queryItems)
		print(URLString + (url?.string ?? ""))
		let requestBuilder: RequestBuilder<LoginResponse>.Type = requestBuilderFactory.getBuilder()
		let res = requestBuilder.init(method: "GET",
									  URLString: (url?.string ?? ""),
									  parameters: [:],
									  isBody: false)
		return res.publisher()
			.mapError { LoginError.requestError($0) }
			.eraseToEffect()
	}
	
	public func resetPass(_ email: String) -> Effect<ForgotPassSuccess, ForgotPassError> {
		let path = ""
		let URLString = baseUrl + path
		var url = URLComponents(string: URLString)
//		let queryItems: [String: Any] = ["username": username, "password": password]
//		url?.queryItems = APIHelper.mapValuesToQueryItems(queryItems)
		
		let requestBuilder: RequestBuilder<ForgotPassSuccess>.Type = requestBuilderFactory.getBuilder()
		let res = requestBuilder.init(method: "GET",
									  URLString: URLString + (url?.string ?? ""),
									  parameters: [:],
									  isBody: false)
		return res.publisher()
			.mapError { ForgotPassError.requestError($0) }
			.eraseToEffect()
	}
}

//URLSession.shared.dataTaskPublisher(for: URL(string: "http://numbersapi.com/\(n)/trivia")!)
//  .map { data, _ in String(decoding: data, as: UTF8.self) }
//  .catch { _ in
//	// Sometimes numbersapi.com can be flakey, so if it ever fails we will just
//	// default to a mock response.
//	Just("\(n) is a good number Brent")
//	  .delay(for: 1, scheduler: DispatchQueue.main)
//  }
//  .mapError { _ in NumbersApiError() }
//  .eraseToEffect()

//var url = URLComponents(string: URLString)
//url?.queryItems = APIHelper.mapValuesToQueryItems([
//	"username": try? newJSONEncoder().encode(username),
//	"password": try? newJSONEncoder().encode(password)
//])
