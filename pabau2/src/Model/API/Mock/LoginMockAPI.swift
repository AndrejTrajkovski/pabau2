import ComposableArchitecture
import Combine
import CasePaths

public struct LoginMockAPI: MockAPI, LoginAPI {
	public func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>> {
		mockSuccess(ForgotPassSuccess())
	}
	
	let delay: Int
	public init (delay: Int) {
		self.delay = delay
	}
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, Error>> {
		mockSuccess(ResetPassSuccess())
	}
	
	public func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
		mockSuccess(User(1, "Andrej"))
	}
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, RequestError>> {
		mockSuccess(ResetPassSuccess())
	}
	
	public func resetPass(_ email: String) -> Effect<Result<ResetPassSuccess, RequestError>> {
		mockSuccess(ResetPassSuccess())
	}
}
