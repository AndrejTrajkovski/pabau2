protocol MockAPI {}

import ComposableArchitecture
import Combine

extension MockAPI {
	func mockError<T: Codable, E: Error>(_ error: E, delay: Double = 1) -> Effect<T, E> {
		return Fail(error: error)
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}

	func mockSuccess<T: Codable, E: Error>(_ value: T, delay: Double = 0.2) -> Effect<T, E> {
		return Just(value)
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.mapError { (error) -> E in return error}
			.eraseToEffect()
	}
}
