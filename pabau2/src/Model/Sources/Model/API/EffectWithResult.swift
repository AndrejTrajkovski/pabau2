import Foundation
import ComposableArchitecture

public typealias EffectWithResult<T, E: Error> = Effect<Result<T, E>, Never>
