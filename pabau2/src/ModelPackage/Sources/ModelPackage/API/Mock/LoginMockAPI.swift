import ComposableArchitecture
import Combine

public struct LoginMockAPI: MockAPI, LoginAPI {
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

	public func login(_ username: String, password: String) -> EffectWithResult<User, LoginError> {
		mockSuccess(User(1, "Andrej"))
	}

	public func sendConfirmation(_ code: String, _ pass: String) -> EffectWithResult<ResetPassSuccess, RequestError> {
		mockSuccess(ResetPassSuccess())
	}

	public func resetPass(_ email: String) -> EffectWithResult<ResetPassSuccess, RequestError> {
		mockSuccess(ResetPassSuccess())
	}
}
