public protocol API {
	var route: String { get }
	var baseAPI: BaseAPI { get }
}

public protocol LoginAPI: API {
	func sendConfirmation(_ code: String, _ pass: String) ->
		RequestBuilder<ResetPassSuccess>
	//	func login(_ username: String, password: String) -> RequestBuilder<User>
	//	func resetPass(_ email: String) -> RequestBuilder<ForgotPassSuccess>
}

struct MockLoginAPI: LoginAPI {
	let route: String = "login"
	let baseAPI: BaseAPI = LiveAPI()
}

struct LiveLoginAPI: LoginAPI {
	let route: String = "login"
	let baseAPI: BaseAPI = LiveAPI()
	
	func sendConfirmation(_ code: String, _ pass: String) -> RequestBuilder<ResetPassSuccess> {
		let URLString = baseAPI.basePath + route
		let parameters: [String:Any]? = nil
		var url = URLComponents(string: URLString)
		url?.queryItems = APIHelper.mapValuesToQueryItems([
			"code": try? newJSONEncoder().encode(code),
			"pass": try? newJSONEncoder().encode(pass)
		])
		
		let requestBuilder: RequestBuilder<ResetPassSuccess>.Type = baseAPI.requestBuilderFactory.getBuilder()
		
		return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false)
	}
	
	//	func login(_ username: String, password: String) -> RequestBuilder<User> {
	//		<#code#>
	//	}
	//
	//	func resetPass(_ email: String) -> RequestBuilder<ForgotPassSuccess> {
	//		<#code#>
	//	}
}
