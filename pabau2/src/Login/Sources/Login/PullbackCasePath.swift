import ComposableArchitecture
//FIXME: 
extension Reducer {
	public func pullbackCp<GlobalState, GlobalAction, GlobalEnvironment>(
		state: CasePath<GlobalState, State>,
		action: CasePath<GlobalAction, Action>,
		environment: @escaping (GlobalEnvironment) -> Environment
	) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
		.init { globalValue, globalAction, globalEnvironment in
			guard let localAction = action.extract(from: globalAction) else { return .none }
			guard let localValue = state.extract(from: globalValue) else { return .none }
			var varLocalValue = localValue
			let localEffect = self(&varLocalValue, localAction, environment(globalEnvironment))
			globalValue = state.embed(varLocalValue)
			return localEffect.map(action.embed)
		}
	}
}
