import Combine
import ComposableArchitecture

public protocol ResponseStatus {
	var success: Bool { get }
	var message: String? { get }
}

public extension Effect where Output: ResponseStatus {
	
	func validate() -> Effect<Output, RequestError> {
		self.tryMap(validate(response:))
			.mapError { $0 as? RequestError ?? .unknown}
			.eraseToEffect()
	}
	
	private func validate(response: Output) throws -> Output {
		guard response.success else {
			throw RequestError.apiError(response.message ?? "Unknown API Error")
		}
		return response
	}
}
