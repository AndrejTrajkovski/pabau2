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
		request.allHTTPHeaderFields = self.headers
		request.httpMethod = method.rawValue
		
		request.httpBody = body
		
		return request
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
				.mapError { $0 as? RequestError ?? .unknown($0) }
				.eraseToAnyPublisher()
		}
	}
}

func bodyData(parameters: [String: Any]) -> Data {
	Data(query(parameters).utf8)
}

func query(_ parameters: [String: Any]) -> String {
	var components: [(String, String)] = []

	for key in parameters.keys.sorted(by: <) {
		let value = parameters[key]!
		components += APIHelper.queryComponents(fromKey: key, value: value)
	}
	return components.map { "\($0)=\($1)" }.joined(separator: "&")
}

func publisher<T: Decodable>(request: URLRequest, dateDecoding: JSONDecoder.DateDecodingStrategy) -> AnyPublisher<T, RequestError> {
//    var log = TextLog()
//    log.write(request.cURL())
	print(request.cURL())
	return URLSession.shared.dataTaskPublisher(for: request)
		.mapError { error in
			RequestError.networking(error)
		}
		.tryMap (validate)
		.mapError { $0 as? RequestError ?? .unknown($0) }
		.flatMap(maxPublishers: .max(1)) { data in
			return decode(data, dateDecoding: dateDecoding)
		}
        .mapError {
            print($0)
            return $0
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
				} else if error is URLError {
					return error as? RequestError ?? .networking(error)
				} else {
					return error as? RequestError ?? .unknown(error)
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

private struct TextLog: TextOutputStream {
    public init () {}

    /// Appends the given string to the stream.
    mutating public func write(_ string: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent("log.txt")

        do {
            let handle = try FileHandle(forWritingTo: log)
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
        } catch {
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: log)
            } catch {
                print(error.localizedDescription)
            }
        }

    }

    public static func retrieveLogFile() throws -> Data {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent("log.txt")
        return try Data.init(contentsOf: log, options: .mappedIfSafe)
//        return try String(contentsOf: log, encoding: .utf8)
    }
}
