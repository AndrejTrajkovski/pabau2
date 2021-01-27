import ComposableArchitecture

public protocol LoginAPI {
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError>
	func login(_ username: String, password: String) -> Effect<LoginResponse, LoginError>
	func resetPass(_ email: String) -> Effect<ForgotPassSuccess, RequestError>
	mutating func updateLoggedIn(user: User)
}
