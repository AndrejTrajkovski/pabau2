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
	public let body: Data?
	public let method: HTTPMethod
	public let baseUrl: String
	public let path: APIPath
	public let dateDecoding: JSONDecoder.DateDecodingStrategy
	
	required public init(method: HTTPMethod,
						 baseUrl: String,
						 path: APIPath,
						 queryParams: [String: Any?]?,
						 headers: [String: String] = [:],
						 dateDecoding: JSONDecoder.DateDecodingStrategy? = nil,
						 body: Data? = nil) {
		self.baseUrl = baseUrl
		self.path = path
		self.method = method
		self.queryParams = queryParams
		self.headers = headers.isEmpty ? defaultHeaders : headers
		self.dateDecoding = dateDecoding ?? .formatted(.rfc3339)
		self.body = body
	}
	
	let defaultHeaders =
		["Content-Type": "application/x-www-form-urlencoded",
		 "Accept-Language": "en;q=1",
		 "User-Agent": defaultUserAgent]
	
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

public enum RequestError: Error, Equatable, CustomStringConvertible {
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
	
	public var description: String {
		switch self {
		case .urlBuilderError(let message):
			return message
		case .emptyDataResponse:
			return "Empty Data Response."
		case .nilHTTPResponse:
			return "Nil HTTP Response."
		case .jsonDecoding(let message):
			return message
		case .networking(let message):
			return message.localizedDescription
		case .generalError(let message):
			return message.localizedDescription
		case .serverError(let message):
			return message
		case .responseNotHTTP:
			return "Response not HTTP."
		case .apiError(let message):
			return message
		case .unknown:
			return "Unknown Error."
		}
	}
}

extension URLRequest {
	public func cURL(pretty: Bool = false) -> String {
		let newLine = pretty ? "\\\n" : ""
		let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
		let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
		
		var cURL = "curl "
		var header = ""
		var data: String = ""
		
		if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
			for (key,value) in httpHeaders {
				header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
			}
		}
		
		if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
			data = "--data '\(bodyString)'"
		}
		
		cURL += method + url + header + data
		
		return cURL
	}
}

private let defaultUserAgent: String = {
	let info = Bundle.main.infoDictionary
	let executable = (info?[kCFBundleExecutableKey as String] as? String) ??
		(ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
		"Unknown"
	let bundle = info?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
	let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
	let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"

	let osNameVersion: String = {
		let version = ProcessInfo.processInfo.operatingSystemVersion
		let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
		let osName: String = {
			#if os(iOS)
			#if targetEnvironment(macCatalyst)
			return "macOS(Catalyst)"
			#else
			return "iOS"
			#endif
			#elseif os(watchOS)
			return "watchOS"
			#elseif os(tvOS)
			return "tvOS"
			#elseif os(macOS)
			return "macOS"
			#elseif os(Linux)
			return "Linux"
			#elseif os(Windows)
			return "Windows"
			#else
			return "Unknown"
			#endif
		}()

		return "\(osName) \(versionString)"
	}()
	
	let userAgent = "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"

	return userAgent
}()
