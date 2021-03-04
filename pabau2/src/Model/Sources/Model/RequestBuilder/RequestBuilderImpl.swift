import Foundation
import Combine
import ComposableArchitecture

public protocol RequestBuilderFactory {
    func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type
}

class RequestBuilderFactoryImpl: RequestBuilderFactory {

	func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
		return RequestBuilderImpl<T>.self
	}
}

open class RequestBuilderImpl<T: Decodable>: RequestBuilder<T> {
	
	func buildRequest() throws -> URLRequest {
		guard var urlComponents = URLComponents(string: baseUrl + path.rawValue) else {
			throw RequestError.urlBuilderError("Invalid path: \(baseUrl + path.rawValue)")
		}
		if let queryParams = queryParams {
			urlComponents.queryItems = APIHelper.mapValuesToQueryItems(queryParams)
		}
		guard let url = urlComponents.url else {
			throw RequestError.urlBuilderError("Invalid url components: \(urlComponents.description)")
		}
		
		var request = URLRequest.init(url: url)
//		application/x-www-form-urlencoded
		request.allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded",
									   "Accept-Language": "en;q=1",
									   "User-Agent": defaultUserAgent]
		request.httpMethod = method.rawValue
		
		if let body = self.body {
			request.httpBody = Data(query(body).utf8)
		}
		
		return request
	}

	func httpBodyData(params: [String: Any]) throws -> Data {
		let jsonString = params.reduce("") { "\($0)\($1.0)=\($1.1)&" }.dropLast()
		guard let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false) else {
			throw RequestError.urlBuilderError("Invalid HTTP body: \(params)")
		}
		return jsonData
	}
	
	private func query(_ parameters: [String: Any]) -> String {
		var components: [(String, String)] = []

		for key in parameters.keys.sorted(by: <) {
			let value = parameters[key]!
			components += APIHelper.queryComponents(fromKey: key, value: value)
		}
		return components.map { "\($0)=\($1)" }.joined(separator: "&")
	}
	
	override func effect() -> Effect<T, RequestError> {
		publisher().eraseToEffect()
	}
	
	override open func publisher() -> AnyPublisher<T, RequestError> {
		do {
			let request = try buildRequest()
			return Model.publisher(request: request, dateDecoding: dateDecoding)
		} catch {
			return Fail(error: error)
				.mapError { $0 as? RequestError ?? .unknown}
				.eraseToAnyPublisher()
		}
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

func publisher<T: Decodable>(request: URLRequest, dateDecoding: JSONDecoder.DateDecodingStrategy) -> AnyPublisher<T, RequestError> {
	return URLSession.shared.dataTaskPublisher(for: request)
		.mapError { error in
			RequestError.networking(error)
		}
		.tryMap (validate)
		.mapError { $0 as? RequestError ?? .unknown }
		.flatMap(maxPublishers: .max(1)) { data in
			return decode(data, dateDecoding: dateDecoding)
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

func decode<T: Decodable>(_ data: Data, dateDecoding: JSONDecoder.DateDecodingStrategy) -> AnyPublisher<T, RequestError> {
	let decoder = JSONDecoder()
	decoder.dateDecodingStrategy = dateDecoding
		return Just(data)
			.decode(type: APIResponse<T>.self, decoder: decoder)
			.tryMap { try $0.result.get() }
			.mapError { error in
				if error is DecodingError {
					var errorMessage = error.localizedDescription + "\n" + (String.init(data: data, encoding: .utf8) ?? ". String not utf8")
					errorMessage += stringIfDecodingError(error) ?? ""
					return RequestError.jsonDecoding(errorMessage)
				} else {
					return error as? RequestError ?? .unknown
				}
		}
		.eraseToAnyPublisher()
}

func stringIfDecodingError(_ error: Error) -> String? {
	if let decodeError = error as? DecodingError {
		switch decodeError {
		case .typeMismatch(let key, let value):
			return("error \(key), value \(value) and ERROR: \(decodeError.localizedDescription)")
		case .valueNotFound(let key, let value):
			return("error \(key), value \(value) and ERROR: \(decodeError.localizedDescription)")
		case .keyNotFound(let key, let value):
			return("error \(key), value \(value) and ERROR: \(decodeError.localizedDescription)")
		case .dataCorrupted(let key):
			return ("error \(key), and ERROR: \(decodeError.localizedDescription)")
		default:
			return ""
		}
	} else {
		return nil
	}
}
