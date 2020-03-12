import CasePaths
import ComposableArchitecture

struct LiveLoginAPI: LoginAPI, LiveAPI {
	func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>> {
		resetPass(email).effect(/ForgotPassError.requestError)
	}
	
	var basePath: String = ""
	let route: String = "login"
	let requestBuilderFactory: RequestBuilderFactory = RequestBuilderFactoryImpl()
	
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, RequestError>> {
		sendConfirmation(code, pass).effect()
	}
	
	func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
		login(username, password: password).effect(/LoginError.requestError)
	}
	
	func login(_ username: String, password: String) -> RequestBuilder<User> {
		let URLString = basePath + route + "login"
		let parameters: [String:Any]? = nil
		var url = URLComponents(string: URLString)
		url?.queryItems = APIHelper.mapValuesToQueryItems([
			"username": try? newJSONEncoder().encode(username),
			"password": try? newJSONEncoder().encode(password)
		])
		let requestBuilder: RequestBuilder<User>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	}
	
	func resetPass(_ email: String) -> RequestBuilder<ForgotPassSuccess> {
		let URLString = basePath + route + "resetPass"
		let parameters: [String:Any]? = nil
		var url = URLComponents(string: URLString)
		url?.queryItems = APIHelper.mapValuesToQueryItems([
			"email": try? newJSONEncoder().encode(email)
		])
		let requestBuilder: RequestBuilder<ForgotPassSuccess>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	}
	
	func sendConfirmation(_ code: String, _ pass: String) -> RequestBuilder<ResetPassSuccess> {
		let URLString = basePath + route + "confirmPass"
		let parameters: [String:Any]? = nil
		var url = URLComponents(string: URLString)
		url?.queryItems = APIHelper.mapValuesToQueryItems([
			"code": try? newJSONEncoder().encode(code),
			"pass": try? newJSONEncoder().encode(pass)
		])
		let requestBuilder: RequestBuilder<ResetPassSuccess>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	}
}
