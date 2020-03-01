import ComposableArchitecture
import Combine

struct MockAPIClient: APIClient {
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, ResetPassBackendError>> {
		return Just(.success(ResetPassSuccess()))
			.delay(for: .seconds(2), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
	
	func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
		return Just(.success(User(id: 1, name: "Andrej")))
			.delay(for: .seconds(2), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
	
	func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>> {
		return Just(.success(ForgotPassSuccess()))
			.delay(for: .seconds(1), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
}