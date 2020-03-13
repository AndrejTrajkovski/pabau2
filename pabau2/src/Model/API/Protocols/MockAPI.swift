protocol MockAPI {}

import ComposableArchitecture
import Combine

extension MockAPI {
	func mockError<T: Codable, E: Error>(_ error: E, delay: Int = 1) -> Effect<Result<T, E>> {
		return Just(.failure(error))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
	
	func mockSuccess<T: Codable, E: Error>(_ value: T, delay: Int = 1) -> Effect<Result<T, E>> {
		return Just(.success(value))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
}