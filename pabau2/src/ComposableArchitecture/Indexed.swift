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
) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> where State: Hashable {
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

extension Array where Element: Hashable {
	func difference(from other: [Element]) -> [Element] {
		let thisSet = Set(self)
		let otherSet = Set(other)
		return Array(thisSet.symmetricDifference(otherSet))
	}
}

//public func indexed<LocalState, LocalAction>(
//	index: Int,
//	value toLocalState: WritableKeyPath<State, [LocalState]>,
//	action toGlobalAction: CasePath<Action, (Int, LocalState.ID, LocalAction)>
//) -> Store<LocalState, LocalAction> where LocalState: Identifiable {
//	var index = index
//	let localStore =
//		Store<LocalState, LocalAction>(
//			initialState: self.state[keyPath: toLocalState][index],
//			reducer: { (localState, localAction, _) -> [Effect<LocalAction>] in
//				let values = self.state[keyPath: toLocalState]
//				if !values.indices.contains(index) || localState.id != values[index].id {
//					guard let newIndex = values.firstIndex(where: { localState.id == $0.id}) else { return [] }
//					index = newIndex
//				}
//				let globalAction = toGlobalAction.embed((index, localState.id, localAction))
//
//				self.send(globalAction)
//				localState = self.state[keyPath: toLocalState][index]
//				return []
//		},
//			environment: self.environment)
//
//	localStore.viewCancellable = self.$state.sink(receiveValue: { [weak localStore] newValue in
//		let values = newValue[keyPath: toLocalState]
//		if !values.indices.contains(index) || localStore?.state.id != values[index].id {
//			guard let newIndex = values.firstIndex(where: { localStore?.state.id == $0.id }) else { return }
//			index = newIndex
//		}
//
//		localStore?.state = newValue[keyPath: toLocalState][index]
//	})
//
//	return localStore
//}
