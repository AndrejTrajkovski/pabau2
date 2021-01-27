import Foundation
import Combine
import ComposableArchitecture


open class RequestBuilder<T> {
	var credential: URLCredential?
	var headers: [String: String]
	public let parameters: [String: Any]?
	public let isBody: Bool
	public let method: String
	public let URLString: String

	required public init(method: String, URLString: String, parameters: [String: Any]?, isBody: Bool, headers: [String: String] = [:]) {
		self.method = method
		self.URLString = URLString
		self.parameters = parameters
		self.isBody = isBody
		self.headers = headers
	}

	func effect<DomainError: Error>(_ toDomainError: CasePath<DomainError, RequestError>) -> EffectWithResult<T, DomainError> {
		return self.publisher()
			.map { Result<T, DomainError>.success($0)}
			.catch { Just(Result<T, DomainError>.failure(toDomainError.embed($0)))}
			.eraseToEffect()
	}

	func effect() -> EffectWithResult<T, RequestError> {
		return self.publisher()
			.map { Result<T, RequestError>.success($0)}
			.catch { Just(Result<T, RequestError>.failure($0))}
			.eraseToEffect()
	}

	open func publisher() -> AnyPublisher<T, RequestError> {
		fatalError()
	}

	open func addHeaders(_ aHeaders: [String: String]) {
		for (header, value) in aHeaders {
			headers[header] = value
		}
	}

	public func addHeader(name: String, value: String) -> Self {
		if !value.isEmpty {
			headers[name] = value
		}
		return self
	}
}

private enum DownloadException: Error {
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
				 (.unknown, .unknown),
				 (.apiError, .apiError):
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
	case apiError(String)
	case unknown
}
