import ComposableArchitecture

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
	
	public func login(_ username: String, password: String) -> Effect<[User], LoginError> {
		struct LoginResponse: Codable {
			let url: String
			public let users: FailableCodableArray<User>

			enum CodingKeys: String, CodingKey {
				case url = "URL"
				case users = "appointments"
			}
		}
		let requestBuilder: RequestBuilder<LoginResponse>.Type = requestBuilderFactory.getBuilder()
		return requestBuilder.init(method: .GET,
								   baseUrl: baseUrl,
								   path: .login,
								   queryParams: ["username": username,
												 "password": password],
								   isBody: false)
			.effect()
			.map(\.users.elements)
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
				"company": $0.companyID,
				"user_id": String($0.userID.rawValue),
				"api_key": $0.apiKey,
			]
		}
	}
	
	func commonParams() -> [String: String] {
		var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		#if DEBUG
			version = "4.6.3"
		#endif
		let userParams = getUserParams() ?? [:]
		let versionParams = ["app_version" : version ?? ""]
		return versionParams.merging(userParams, uniquingKeysWith: { old, new in return old })
	}
}
