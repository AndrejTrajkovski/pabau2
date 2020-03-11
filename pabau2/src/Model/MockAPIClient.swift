import ComposableArchitecture
import Combine
import CasePaths

public protocol LiveAPI {
	var basePath: String { get }
	var route: String { get }
	var requestBuilderFactory: RequestBuilderFactory { get }
}

protocol MockAPI {}

extension MockAPI {
	func mockError<T: Codable, E: Error>(_ error: E, delay: Int = 1) -> Effect<Result<T, E>> {
		return Just(.failure(error))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
	
	func mockSuccess<T: Codable, E: Error>(_ value: T, delay: Int = 1) -> Effect<Result<T, E>> {
		return Just(.success(value))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
}

public struct LoginMockAPI: MockAPI, LoginAPI {
	public func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>> {
		mockSuccess(ForgotPassSuccess())
	}
	
	let delay: Int
	public init (delay: Int) {
		self.delay = delay
	}
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, Error>> {
		mockSuccess(ResetPassSuccess())
	}
	
	public func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
		mockSuccess(User(1, "Andrej"))
	}
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, RequestError>> {
		mockSuccess(ResetPassSuccess())
	}
	
	public func resetPass(_ email: String) -> Effect<Result<ResetPassSuccess, RequestError>> {
		mockSuccess(ResetPassSuccess())
	}
}

fileprivate enum DownloadException : Error {
	case responseDataMissing
	case responseFailed
	case requestMissing
	case requestMissingPath
	case requestMissingURL
}

public enum RequestError: Error, Equatable {
	public static func == (lhs: RequestError, rhs: RequestError) -> Bool {
		switch (lhs, rhs) {
		case (.urlBuilderError, .urlBuilderError),
				 (.emptyDataResponse, .emptyDataResponse),
				 (.nilHTTPResponse, .nilHTTPResponse),
				 (.jsonDecoding, .jsonDecoding),
				 (.networking, .networking),
				 (.generalError, .generalError),
				 (.serverError, .serverError),
				 (.responseNotHTTP, .responseNotHTTP),
				 (.unknown, .unknown):
			return true
		default:
			return false
		}
	}
	
	case urlBuilderError
	case emptyDataResponse
	case nilHTTPResponse
	case jsonDecoding(String)
	case networking(Error)
	case generalError(Error)
	case serverError(String)
	case responseNotHTTP
	case unknown
}
