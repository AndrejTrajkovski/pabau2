import Foundation
import Combine
import ComposableArchitecture

public enum HTTPMethod: String {
	case GET
	case POST
}

open class RequestBuilder<T> {
	var credential: URLCredential?
	var headers: [String: String]
	public let queryParams: [String: Any?]?
	public let isBody: Bool
	public let method: HTTPMethod
	public let baseUrl: String
	public let path: APIPath

	required public init(method: HTTPMethod,
						 baseUrl: String,
						 path: APIPath,
						 queryParams: [String: Any?]?,
						 isBody: Bool,
						 headers: [String: String] = [:]) {
		self.baseUrl = baseUrl
		self.path = path
		self.method = method
		self.queryParams = queryParams
		self.isBody = isBody
		self.headers = headers
	}

	func effect<DomainError: Error>(toDomainError: @escaping (RequestError) -> DomainError) -> Effect<T, DomainError> {
		fatalError("override in superclass")
	}
	
	func effect() -> Effect<T, RequestError> {
		fatalError("override in superclass")
	}

	func publisher() -> AnyPublisher<T, RequestError> {
		fatalError("override in superclass")
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

	case urlBuilderError(String)
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
