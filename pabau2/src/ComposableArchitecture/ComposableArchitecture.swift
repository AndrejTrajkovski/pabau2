import CasePaths
import Combine
import SwiftUI

// swiftlint:disable force_cast
public struct Reducer<Value, Action, Environment> {
  let reducer: (inout Value, Action, Environment) -> [Effect<Action>]

  public init(_ reducer: @escaping (inout Value, Action, Environment) -> [Effect<Action>]) {
    self.reducer = reducer
  }
}

extension Reducer {
  public func callAsFunction(_ value: inout Value, _ action: Action, _ environment: Environment) -> [Effect<Action>] {
    self.reducer(&value, action, environment)
  }
}

extension Reducer {
  public static func combine(_ reducers: Reducer...) -> Reducer {
    .init { value, action, environment in
      let effects = reducers.flatMap { $0(&value, action, environment) }
      return effects
    }
  }
}

extension Reducer {
	public var optional: Reducer<Value?, Action, Environment> {
		.init { value, action, environment in
			guard value != nil else { return [] }
			return self(&value!, action, environment)
		}
	}
}

//public func combine<Value, Action, Environment>(
//  _ reducers: Reducer<Value, Action, Environment>...
//) -> Reducer<Value, Action, Environment> {
//  .init { value, action, environment in
//    let effects = reducers.flatMap { $0(&value, action, environment) }
//    return effects
//  }
//}

extension Reducer {
  public func pullback<GlobalValue, GlobalAction, GlobalEnvironment>(
    value: WritableKeyPath<GlobalValue, Value>,
    action: CasePath<GlobalAction, Action>,
    environment: @escaping (GlobalEnvironment) -> Environment
  ) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
    .init { globalValue, globalAction, globalEnvironment in
      guard let localAction = action.extract(from: globalAction) else { return [] }
      let localEffects = self(&globalValue[keyPath: value], localAction, environment(globalEnvironment))

      return localEffects.map { localEffect in
        localEffect.map(action.embed)
          .eraseToEffect()
      }
    }
  }
}

//public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, LocalEnvironment, GlobalEnvironment>(
//  _ reducer: Reducer<LocalValue, LocalAction, LocalEnvironment>,
//  value: WritableKeyPath<GlobalValue, LocalValue>,
//  action: CasePath<GlobalAction, LocalAction>,
//  environment: @escaping (GlobalEnvironment) -> LocalEnvironment
//) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
//  return .init { globalValue, globalAction, globalEnvironment in
//    guard let localAction = action.extract(from: globalAction) else { return [] }
//    let localEffects = reducer(&globalValue[keyPath: value], localAction, environment(globalEnvironment))
//
//    return localEffects.map { localEffect in
//      localEffect.map(action.embed)
//        .eraseToEffect()
//    }
//  }
//}

extension Reducer {
  public func logging(
    printer: @escaping (Environment) -> (String) -> Void = { _ in { print($0) } }
  ) -> Reducer {
    .init { value, action, environment in
      let effects = self(&value, action, environment)
      let newValue = value
      let print = printer(environment)
      return [.fireAndForget {
        print("Action: \(action)")
        print("Value:")
        var dumpedNewValue = ""
        dump(newValue, to: &dumpedNewValue)
        print(dumpedNewValue)
        print("---")
        }] + effects
    }
  }
}

//public func logging<Value, Action, Environment>(
//  _ reducer: Reducer<Value, Action, Environment>
//) -> Reducer<Value, Action, Environment> {
//  return .init { value, action, environment in
//    let effects = reducer(&value, action, environment)
//    let newValue = value
//    return [.fireAndForget {
//      print("Action: \(action)")
//      print("Value:")
//      dump(newValue)
//      print("---")
//      }] + effects
//  }
//}

public final class Store<Value, Action> {
  private let reducer: Reducer<Value, Action, Any>
  private let environment: Any
  @Published private var value: Value
  private var viewCancellable: Cancellable?
  private var effectCancellables: Set<AnyCancellable> = []

  public init<Environment>(
    initialValue: Value,
    reducer: Reducer<Value, Action, Environment>,
    environment: Environment
  ) {
    self.reducer = .init { value, action, environment in
      reducer(&value, action, environment as! Environment)
    }
    self.value = initialValue
    self.environment = environment
  }

  private func send(_ action: Action) {
    let effects = self.reducer(&self.value, action, self.environment)
    effects.forEach { effect in
      var effectCancellable: AnyCancellable?
      var didComplete = false
      effectCancellable = effect.sink(
        receiveCompletion: { [weak self, weak effectCancellable] _ in
          didComplete = true
          guard let effectCancellable = effectCancellable else { return }
          self?.effectCancellables.remove(effectCancellable)
      },
        receiveValue: { [weak self] in self?.send($0) }
      )
      if !didComplete, let effectCancellable = effectCancellable {
        self.effectCancellables.insert(effectCancellable)
      }
    }
  }

  public func scope<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: .init { localValue, localAction, _ in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return []
    },
      environment: self.environment
    )
    localStore.viewCancellable = self.$value
      .map(toLocalValue)
      .sink { [weak localStore] newValue in
        localStore?.value = newValue
      }
    return localStore
  }
}

public final class ViewStore<Value, Action>: ObservableObject {
  @Published public fileprivate(set) var value: Value
  fileprivate var cancellable: Cancellable?
  public let send: (Action) -> Void

  public init(
    initialValue value: Value,
    send: @escaping (Action) -> Void
  ) {
    self.value = value
    self.send = send
  }
}

extension Store where Value: Equatable {
  public var view: ViewStore<Value, Action> {
    self.view(removeDuplicates: ==)
  }
}

extension Store {
  public func view(
    removeDuplicates predicate: @escaping (Value, Value) -> Bool
  ) -> ViewStore<Value, Action> {
    let viewStore = ViewStore(
      initialValue: self.value,
      send: self.send
    )

    viewStore.cancellable = self.$value
      .removeDuplicates(by: predicate)
      .sink(receiveValue: { [weak viewStore] value in
        viewStore?.value = value
      })

    return viewStore
  }
}
// swiftlint:enable force_cast

extension Reducer {
	public func pullback<GlobalValue, GlobalAction, GlobalEnvironment>(
		value: CasePath<GlobalValue, Value>,
		action: CasePath<GlobalAction, Action>,
		environment: @escaping (GlobalEnvironment) -> Environment
	) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
		.init { globalValue, globalAction, globalEnvironment in
			guard let localAction = action.extract(from: globalAction) else { return [] }
			guard let localValue = value.extract(from: globalValue) else { return [] }
			var varLocalValue = localValue
			let localEffects = self(&varLocalValue, localAction, environment(globalEnvironment))
			globalValue = value.embed(varLocalValue)
			return localEffects.map { localEffect in
				localEffect.map(action.embed)
					.eraseToEffect()
			}
		}
	}
}

extension ViewStore {
  public func binding<LocalValue>(
    get: @escaping (Value) -> LocalValue,
    send action: Action
  ) -> Binding<LocalValue> {
    Binding(
      get: { get(self.value) },
      set: { _ in self.send(action) }
    )
  }

	public func binding<LocalValue>(
		get: @escaping (Value) -> LocalValue,
		send toAction: @escaping (LocalValue) -> Action
	) -> Binding<LocalValue> {
		Binding(
			get: { get(self.value) },
			set: { self.send(toAction($0)) }
		)
	}

	public func binding<T>(value: KeyPath<Value, T>,
												 action: CasePath<Action, T>) -> Binding<T> {
		Binding<T>(
			get: { self.value[keyPath: value]  },
			set: { self.send(action.embed($0)) }
		)
	}
}

extension Store {
	public func indexed<LocalState, LocalAction>(
		index: Int,
		value toLocalState: WritableKeyPath<Value, [LocalState]>,
		action toGlobalAction: CasePath<Action, (Int, LocalState.ID, LocalAction)>
	) -> Store<LocalState, LocalAction> where LocalState: Identifiable {
		var index = index
		let localStore =
			Store<LocalState, LocalAction>(
				initialValue: self.value[keyPath: toLocalState][index],
				reducer: .init { (localState, localAction, _) -> [Effect<LocalAction>] in
					let values = self.value[keyPath: toLocalState]
					if !values.indices.contains(index) || localState.id != values[index].id {
						guard let newIndex = values.firstIndex(where: { localState.id == $0.id}) else { return [] }
						index = newIndex
					}
					let globalAction = toGlobalAction.embed((index, localState.id, localAction))
					self.send(globalAction)
					localState = self.value[keyPath: toLocalState][index]
					return []
				},
				environment: self.environment)
		localStore.viewCancellable = self.$value.sink(receiveValue: { [weak localStore] newValue in
			let values = newValue[keyPath: toLocalState]
			if !values.indices.contains(index) || localStore?.value.id != values[index].id {
				guard let newIndex = values.firstIndex(where: { localStore?.value.id == $0.id }) else { return }
				index = newIndex
			}
			localStore?.value = newValue[keyPath: toLocalState][index]
		})
		return localStore
	}
}
