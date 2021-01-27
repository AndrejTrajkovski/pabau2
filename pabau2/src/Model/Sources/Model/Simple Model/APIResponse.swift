import Combine

public protocol ResponseStatus {
	var success: Bool { get }
	var message: String? { get }
}

extension Publisher where Output: ResponseStatus, Failure == RequestError {
	
	public func validate() -> AnyPublisher<Output, Failure> {
		self.tryMap(validate(response:))
			.mapError { $0 as? RequestError ?? .unknown}
			.eraseToAnyPublisher()
	}
	
	private func validate(response: Output) throws -> Output {
		guard response.success else {
			throw RequestError.apiError(response.message ?? "Unknown API Error")
		}
		return response
	}
}
