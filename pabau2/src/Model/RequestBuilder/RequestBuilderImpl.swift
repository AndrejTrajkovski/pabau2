import Foundation
import Combine

class RequestBuilderFactoryImpl: RequestBuilderFactory {

	func getBuilder<T:Decodable>() -> RequestBuilder<T>.Type {
		return RequestBuilderImpl<T>.self
	}
}

open class RequestBuilderImpl<T:Decodable>: RequestBuilder<T> {

	override open func publisher() -> AnyPublisher<T, RequestError> {
		guard let url = URL(string: self.URLString) else {
			return Fail(error: RequestError.urlBuilderError).eraseToAnyPublisher()
		}
		var request = URLRequest.init(url: url)
		request.allHTTPHeaderFields = ["Content-Type": "application/json"]

		return URLSession.shared.dataTaskPublisher(for: request)
			.mapError { error in
				RequestError.networking(error)
		}
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
