import ComposableArchitecture

public typealias EffectWithResult<T, E: Error> = Effect<Result<T, E>, Never>

public protocol LoginAPI {
	func sendConfirmation(_ code: String, _ pass: String) -> EffectWithResult<ResetPassSuccess, RequestError>
	func login(_ username: String, password: String) -> EffectWithResult<User, LoginError>
	func resetPass(_ email: String) -> EffectWithResult<ForgotPassSuccess, ForgotPassError>
}
