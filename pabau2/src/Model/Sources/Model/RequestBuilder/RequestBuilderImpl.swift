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
		request.allHTTPHeaderFields = ["Content-Type": "application/json"]
		request.httpMethod = method.rawValue
		return request
	}

	override func effect() -> Effect<T, RequestError> {
		publisher().eraseToEffect()
	}
	
	override open func publisher() -> AnyPublisher<T, RequestError> {
		do {
			let request = try buildRequest()
			print(request)
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
		} catch {
			return Fail(error: error)
				.mapError { $0 as? RequestError ?? .unknown}
				.eraseToAnyPublisher()
		}
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
        decoder.dateDecodingStrategy = .formatted(.rfc3339)

			return Just(data)
				.decode(type: T.self, decoder: decoder)
				.mapError { error in
					var errorMessage = error.localizedDescription + "\n" + (String.init(data: data, encoding: .utf8) ?? ". String not utf8")
					errorMessage += self.stringIfDecodingError(error) ?? ""
					return RequestError.jsonDecoding(errorMessage)
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
}
