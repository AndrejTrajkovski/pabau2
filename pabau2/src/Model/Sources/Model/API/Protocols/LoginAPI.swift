import ComposableArchitecture

public protocol LoginAPI {
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<ResetPassSuccess, RequestError>
	func login(_ username: String, password: String) -> Effect<[User], LoginError>
	func resetPass(_ email: String) -> Effect<ForgotPassSuccess, RequestError>
	func updateLoggedIn(user: User)
}
