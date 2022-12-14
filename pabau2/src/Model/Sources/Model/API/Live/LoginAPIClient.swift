import ComposableArchitecture

//MARK: - LoginAPI
extension APIClient {
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError> {
		let requestBuilder: RequestBuilder<ResetPassSuccess>.Type = requestBuilderFactory.getBuilder()
		let res = requestBuilder.init(method: .GET,
									  baseUrl: baseUrl,
									  path: .sendConfirmation,
									  queryParams: [:]
		)
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
												 "password": password]
		)
			.effect()
			.map(\.users.elements)
			.mapError { LoginError.requestError($0) }
			.eraseToEffect()
	}
	
	public func resetPass(_ email: String) -> Effect<ForgotPassSuccess, RequestError> {
		let requestBuilder: RequestBuilder<ForgotPassSuccess>.Type = requestBuilderFactory.getBuilder()
        let bodyValues = "email=\(email)&forgot_password_ios=true".data(using: .utf8)

		return requestBuilder.init(method: .POST,
								   baseUrl: forgotPwBaseUrl,
                                   path: .resetPass,
                                   queryParams: [:],
                                   body: bodyValues
		)
			.effect()
	}
	
	func commonAnd(other: [String: Any]) -> [String: Any] {
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
	
	func commonParams() -> [String: Any] {
		var version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
//		#if DEBUG
        version = "4.6.3"//has to be like this for backend check
//		#endif
		let userParams = getUserParams() ?? [:]
		let versionParams = ["app_version" : version ?? ""]
		return versionParams.merging(userParams, uniquingKeysWith: { old, new in return old })
	}
}
