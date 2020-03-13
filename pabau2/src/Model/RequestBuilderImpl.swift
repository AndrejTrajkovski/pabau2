import Foundation
import Combine

class RequestBuilderFactoryImpl: RequestBuilderFactory {

	func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
		return RequestBuilderImpl<T>.self
	}
}

private enum DownloadException: Error {
	case responseDataMissing
	case responseFailed
	case requestMissing
	case requestMissingPath
	case requestMissingURL
}

public enum RequestBuilderError: Error {
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

open class RequestBuilderImpl<T: Decodable>: RequestBuilder<T> {

	override open func publisher() -> AnyPublisher<T, RequestBuilderError> {
		guard let url = URL(string: self.URLString) else {
			return Fail(error: RequestBuilderError.urlBuilderError).eraseToAnyPublisher()
		}
		var request = URLRequest.init(url: url)
		request.allHTTPHeaderFields = ["Content-Type": "application/json"]
		request.httpMethod = method

		return URLSession.shared.dataTaskPublisher(for: request)
			.mapError { error in RequestBuilderError.networking(error)}
			.tryMap (self.validate)
			.mapError { $0 as? RequestBuilderError ?? .unknown }
			.flatMap(maxPublishers: .max(1)) { data in
				return self.decode(data)
			}
			.eraseToAnyPublisher()
	}

	func validate(data: Data, response: URLResponse) throws -> Data {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw RequestBuilderError.responseNotHTTP
		}
		guard httpResponse.statusCode == 200 else { throw RequestBuilderError.serverError(
			String(httpResponse.statusCode) + HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
		}
		return data
	}

	func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T,
		RequestBuilderError> {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .secondsSince1970

			return Just(data)
				.decode(type: T.self, decoder: decoder)
				.mapError { error in
					return RequestBuilderError.jsonDecoding(error.localizedDescription + "\n" + (String.init(data: data, encoding: .utf8) ?? ". String not utf8"))
			}
			.eraseToAnyPublisher()
	}
}
