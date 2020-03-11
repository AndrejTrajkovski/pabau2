import ComposableArchitecture
import Combine
import CasePaths

public struct MockAPIClient: APIClient {
	
	let delay: Int
	public init (delay: Int) {
		self.delay = delay
	}
	
	private func mock<T: Codable, E: Error>(_ value: T, delay: Int = 1) -> Effect<Result<T, E>> {
		return Just(.success(value))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
	
	public func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, Error>> {
		mock(ResetPassSuccess())
	}
		
	public func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
		return mock(User(1, "Andrej"))
	}
	
	public func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, ForgotPassError>> {
		return mock(ForgotPassSuccess())
	}
}

//TODO: Differentiate HTTP Methods, GET, POST
struct LiveAPIClient {
//	func login(_ username: String, password: String) -> Effect<Result<User, LoginError>> {
//	}
//
	func resetPass(_ email: String) -> Effect<Result<ForgotPassSuccess, Error>> {
		get()
	}
	
	func sendConfirmation(_ code: String, _ pass: String) -> Effect<Result<ResetPassSuccess, LoginError>> {
		return get(casePath: /LoginError.requestError)
	}
	
	func get<T: Codable>() -> Effect<Result<T, Error>> {
			return publisher(url: URL.init(string: "sendconfirmation")!)
				.map { Result.success($0)}
				.catch { Just(Result.failure($0))}
				.eraseToEffect()
	}
	
	func get<T: Codable, DomainError: Error>(casePath: CasePath<DomainError, RequestError>) ->
		Effect<Result<T, DomainError>> {
			return publisher(url: URL.init(string: "sendconfirmation")!)
				.map { Result.success($0)}
				.catch { Just(Result.failure(casePath.embed($0)))}
				.eraseToEffect()
	}
	
	func publisher<T: Codable>(url: URL) -> AnyPublisher<T, RequestError> {
		var request = URLRequest.init(url: url)
		request.allHTTPHeaderFields = ["Content-Type": "application/json"]
		
		return URLSession.shared.dataTaskPublisher(for: request)
			.mapError { error in RequestError.networking(error)}
			.tryMap (self.validate)
			.mapError { $0 as? RequestError ?? .unknown }
			.flatMap(maxPublishers: .max(1)) { data in
				return self.decode(data)
		}
		.eraseToAnyPublisher()
	}
	
	func validate(data: Data, response: URLResponse) throws -> Data {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw RequestError.responseNotHTTP
		}
		guard httpResponse.statusCode == 200 else { throw RequestError.serverError(
			String(httpResponse.statusCode) + HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
		}
		return data
	}
	
	func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T,
		RequestError> {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .secondsSince1970
			
			return Just(data)
				.decode(type: T.self, decoder: decoder)
				.mapError { error in
					return RequestError.jsonDecoding(error.localizedDescription + "\n" + (String.init(data: data, encoding: .utf8) ?? ". String not utf8"))
			}
			.eraseToAnyPublisher()
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

extension Publisher where Output == Result<Codable, RequestError>, Failure == Never {
	func mapFailure<DomainError>(casePath: CasePath<DomainError, RequestError>) -> AnyPublisher<Result<Codable, DomainError>, Never> {
		self.map { (result) -> Result<Codable, DomainError> in
			result.mapError(casePath.embed)
		}.eraseToAnyPublisher()
	}
}
//func Effect<Result<T, Error>> -> Effect<Result<T, LoginError>>
