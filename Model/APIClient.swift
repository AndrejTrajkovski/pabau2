import ComposableArchitecture
import Combine

protocol APIClient {
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, ResetPassBackendError>>
	func login(_ username: String, password: String) -> Effect<Result<User, LoginError>>
	func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>>
}
