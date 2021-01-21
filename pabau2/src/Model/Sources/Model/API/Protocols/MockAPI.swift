protocol MockAPI {}

import ComposableArchitecture
import Combine

extension MockAPI {
	func mockError<T: Codable, E: Error>(_ error: E, delay: Double = 1) -> EffectWithResult<T, E> {
		return Just(.failure(error))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}

	func mockSuccess<T, E: Error>(_ value: T, delay: Double = 0.2) -> EffectWithResult<T, E> {
		return Just(.success(value))
			.delay(for: .seconds(delay), scheduler: DispatchQueue.main)
			.eraseToEffect()
	}
}
