import ComposableArchitecture

public protocol LoginAPI {
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, RequestError>>
	func login(_ username: String, password: String) -> Effect<Result<User, LoginError>>
	func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>>
}
