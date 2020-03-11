import ComposableArchitecture
import Combine

public protocol APIClient {
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, Error>>
		func login(_ username: String, password: String) -> Effect<Result<User, LoginError>>
		func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>>
}
