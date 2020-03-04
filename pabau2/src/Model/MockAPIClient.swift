import ComposableArchitecture
import Combine

public struct MockAPIClient: APIClient {
	let delay: Int
	public init (delay: Int) {
		self.delay = delay
	}

	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, ResetPassBackendError>> {
		return Just(.success(ResetPassSuccess()))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}

	public func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
		return Just(.success(User(id: 1, name: "Andrej")))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}

	public func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>> {
		return Just(.success(ForgotPassSuccess()))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
}
