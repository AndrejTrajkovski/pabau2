import ComposableArchitecture
import Combine

public struct LoginMockAPI: MockAPI, LoginAPI {
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError> {
		Just(ResetPassSuccess())
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.mapError { _ in RequestError.unknown }
			.eraseToEffect()
	}
	
	public func login(_ username: String, password: String) -> Effect<LoginResponse, LoginError> {
		let user = User(userID: "1", companyID: "", fullName: "", avatar: "", logo: "", expired: false, headerTheme: "", backgroundImage: "", videoURL: "", buttonCol: "", podURL: "", companyName: "", companyCity: "", company2Fa: 123, authorizedDevices: 123, googleAuth: 123, apiKey: "")
		let response = LoginResponse(success: true, total: 20, url: "", users: [user])
		return Just(response)
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.mapError { _ in LoginError.wrongCredentials }
			.eraseToEffect()
	}
	
	public func resetPass(_ email: String) -> Effect<ForgotPassSuccess, ForgotPassError> {
		Just(ForgotPassSuccess())
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.mapError { _ in ForgotPassError.serviceNotAvailable }
			.eraseToEffect()
	}
	
	public func resetPass(_ email: String) -> EffectWithResult<ForgotPassSuccess, ForgotPassError> {
		mockSuccess(ForgotPassSuccess())
	}

	let delay: Int
	public init (delay: Int) {
		self.delay = delay
	}

	public func sendConfirmation(_ code: String, _ pass: String) -> EffectWithResult<ResetPassSuccess, Error> {
		mockSuccess(ResetPassSuccess())
	}
}
