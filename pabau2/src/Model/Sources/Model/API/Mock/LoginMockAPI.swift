import ComposableArchitecture
import Combine

public struct LoginMockAPI: MockAPI, LoginAPI {
	
	public func updateLoggedIn(user: User) {
		
	}
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError> {
		Just(ResetPassSuccess(success: true, message: nil))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.mapError { _ in RequestError.unknown }
			.eraseToEffect()
	}
	
	public func login(_ username: String, password: String) -> Effect<LoginResponse, LoginError> {
		let user = User(userID: 1, companyID: "", fullName: "", avatar: "", logo: "", companyName: "", apiKey: "")
		let response = LoginResponse(success: true, message: nil, url: "", users: [user])
		return Just(response)
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.mapError { _ in LoginError.wrongCredentials }
			.eraseToEffect()
	}
	
	public func resetPass(_ email: String) -> Effect<ForgotPassSuccess, RequestError> {
		mockSuccess(ForgotPassSuccess(success: true, message: nil))
	}

	let delay: Int
	public init (delay: Int) {
		self.delay = delay
	}

	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, Error> {
		mockSuccess(ResetPassSuccess(success: true, message: nil))
	}
}
