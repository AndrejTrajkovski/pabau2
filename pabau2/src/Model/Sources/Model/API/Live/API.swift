import Foundation
import ComposableArchitecture

struct APIClient: LoginAPI {
	
	var baseUrl: String = "https://crm.pabau.com"
	var loggedInUser: User?
	public var requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
	
	
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError> {
		let requestBuilder: RequestBuilder<ResetPassSuccess>.Type = requestBuilderFactory.getBuilder()
		let res = requestBuilder.init(method: "GET", URLString: "", parameters: [:], isBody: false)
		return res.effect()
	}
	
	func login(_ username: String, password: String) -> EffectWithResult<User, LoginError> {
		return loginResponse(username, password: password).map { $0.map {
			$0.users.first!
		}}
	}
	
	func login(_ username: String, password: String) -> Effect<LoginResponse, LoginError> {
		let path = "OAuth2/staff/login-check.php"
		let URLString = baseUrl + path
		var url = URLComponents(string: URLString)
		let queryItems: [String: Any] = ["username": username, "password": password]
		url?.queryItems = APIHelper.mapValuesToQueryItems(queryItems)
		
		let requestBuilder: RequestBuilder<LoginResponse>.Type = requestBuilderFactory.getBuilder()
		let res = requestBuilder.init(method: "GET",
									  URLString: URLString + (url?.string ?? ""),
									  parameters: [:],
									  isBody: false)
		return res.effect(/LoginError.requestError)
	}
	
	func resetPass(_ email: String) -> Effect<ForgotPassSuccess, ForgotPassError> {
		
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
