import ComposableArchitecture

public protocol LoginAPI {
	func sendConfirmation(_ code: String, _ pass: String) -> EffectWithResult<ResetPassSuccess, RequestError>
	func login(_ username: String, password: String) -> EffectWithResult<User, LoginError>
	func resetPass(_ email: String) -> EffectWithResult<ForgotPassSuccess, ForgotPassError>
}
