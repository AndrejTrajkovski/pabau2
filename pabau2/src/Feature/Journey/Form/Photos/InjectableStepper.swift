import SwiftUI
import ComposableArchitecture

public let injectableStepperReducer = Reducer<InjectableStepperState, InjectableStepperAction, JourneyEnvironment>.init {
	state, action, _ in
	
	func calc(increment: inout Double,
						activeInjState: inout InjectionsAndActive,
						action: InjectableStepperAction,
						injectable: Injectable) {
		if let activeInjId = activeInjState.activeInjectionId {
			var activeInj = activeInjState.injections[id: activeInjId]!
			switch action {
			case .increment:
				activeInj.units += increment
			case .decrement:
				activeInj.units -= increment
			}
			activeInjState.injections[id: activeInjId] = activeInj
		} else {
			calc(increment: &increment,
					 injectable: injectable,
					 action: action)
		}
	}
	
	func calc(increment: inout Double,
						injectable: Injectable,
						action: InjectableStepperAction) {
		switch action {
		case .increment:
			increment += injectable.increment
		case .decrement:
			increment -= injectable.increment
		}
	}
	
	switch state.type {
	case .activeInjections(var injections):
		calc(increment: &state.injectable.increment,
				 activeInjState: &injections,
				 action: action,
				 injectable: state.injectable)
		state.type = .activeInjections(injections)
	case .noInjections(var increment):
		calc(increment: &increment,
				 injectable: state.injectable,
				 action: action)
		state.type = .noInjections(increment: increment)
	}
	return .none
}

public struct InjectableStepperState: Equatable {
	var type: InjectableStepperType
	var injectable: Injectable
	
	init(injectable: Injectable) {
		self.type = .noInjections(increment: injectable.increment)
		self.injectable = injectable
	}
	
	init(usedInjections: InjectionsAndActive,
			 injectable: Injectable) {
		self.type = .activeInjections(usedInjections)
		self.injectable = injectable
	}
}

public enum InjectableStepperType: Equatable {
	case activeInjections(InjectionsAndActive)
	case noInjections(increment: Double)
}

public struct UsedInjectionsState: Equatable {
	var injections: [Injection] = []
	var activeInjection: Injection?
	
	init(_ injections: [Injection]) {
		self.injections = injections
		self.activeInjection = injections.last
	}
}

public enum InjectableStepperAction: Equatable{
	case increment
	case decrement
}

struct InjectableStepper: View {
	let store: Store<InjectableStepperState, InjectableStepperAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			HStack {
				InjectableStepperTop(store: self.store.scope(state: { $0 },
																										action: { $0 }))
				Spacer()
				HStack {
					Button(action: { viewStore.send(.decrement) },
								 label: { Image(systemName: "minus.rectangle.fill") })
					Text("").font(.regular17)
					Button(action: { viewStore.send(.increment )},
								 label: { Image(systemName: "plus.rectangle.fill") })
				}
			}
		}
	}
}

struct InjectableStepperTop: View {
	let store: Store<InjectableStepperState, InjectableStepperAction>
	
	struct State: Equatable {
		let color: Color
		let injTitle: String
		let desc: String
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			VStack {
				HStack {
					Circle()
						.fill(viewStore.state.color)
						.frame(width: 10, height: 10)
					Text(viewStore.state.injTitle).font(.medium16)
				}
				Text(viewStore.state.desc)
			}
		}
	}
}

extension InjectableStepperTop.State {
  init(state: InjectableStepperState) {
		self.color = state.injectable.color
		self.injTitle = state.injectable.title
		switch state.type {
		case .activeInjections(let usedInj):
			let total = usedInj.injections.reduce(into: TotalInjAndUnits.init(), { res, element in
				res.totalUnits += element.units
				res.totalInj += 1
			})
			self.desc = "Selection: \(total.totalInj) injections - \(total.totalUnits)"
		case .noInjections:
			self.desc = "Selection: 0 injections - 0 units"
		}
	}
}
