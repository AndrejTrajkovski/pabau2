import CasePaths

public struct Indexed<Value> {
	public var index: Int
	public var value: Value
	public init(index: Int, value: Value) {
		self.index = index
		self.value = value
	}
}

public func indexed<State, Action, GlobalState, GlobalAction,
	LocalEnvironment, GlobalEnvironment>(
	reducer: Reducer<State, Action, LocalEnvironment>,
	_ stateKeyPath: WritableKeyPath<GlobalState, [State]>,
	_ actionCasePath: CasePath<GlobalAction, Indexed<Action>>,
	_ environment: @escaping (GlobalEnvironment) -> LocalEnvironment
) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
	.init { globalValue, globalAction, globalEnvironment in
		guard let localAction = actionCasePath.extract(from: globalAction) else { return [] }
		let index = localAction.index
		let localEffects = reducer(&globalValue[keyPath: stateKeyPath][index], localAction.value, environment(globalEnvironment))
		return localEffects.map { localEffect in
			localEffect.map { localAction in
				actionCasePath.embed(Indexed(index: index, value: localAction))
			}.eraseToEffect()
		}
	}
}
