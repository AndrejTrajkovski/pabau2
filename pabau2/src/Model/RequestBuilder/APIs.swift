import Foundation
import Combine
import ComposableArchitecture
import CasePaths

extension RequestBuilder where T: Codable {
	
	func effect<DomainError: Error>(_ toDomainError: CasePath<DomainError, RequestError>) -> Effect<Result<T, DomainError>> {
		return self.publisher()
			.map { Result<T, DomainError>.success($0)}
			.catch { Just(Result<T, DomainError>.failure(toDomainError.embed($0)))}
			.eraseToEffect()
	}
	
	func effect() -> Effect<Result<T, RequestError>> {
		return self.publisher()
			.map { Result<T, RequestError>.success($0)}
			.catch { Just(Result<T, RequestError>.failure($0))}
			.eraseToEffect()
	}
}

open class RequestBuilder<T> {
	var credential: URLCredential?
	var headers: [String:String]
	public let parameters: [String:Any]?
	public let isBody: Bool
	public let method: String
	public let URLString: String
	
	required public init(method: String, URLString: String, parameters: [String:Any]?, isBody: Bool, headers: [String:String] = [:]) {
		self.method = method
		self.URLString = URLString
		self.parameters = parameters
		self.isBody = isBody
		self.headers = headers
	}
	
	open func publisher() -> AnyPublisher<T, RequestError> {
		fatalError()
	}
	
	open func addHeaders(_ aHeaders:[String:String]) {
		for (header, value) in aHeaders {
			headers[header] = value
		}
	}
	
	open func execute(_ completion: @escaping (_ response: Response<T>?, _ error: Error?) -> Void) { }
	
	public func addHeader(name: String, value: String) -> Self {
		if !value.isEmpty {
			headers[name] = value
		}
		return self
	}
}

public protocol RequestBuilderFactory {
	func getBuilder<T:Decodable>() -> RequestBuilder<T>.Type
}
