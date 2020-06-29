import SwiftUI
import ComposableArchitecture

public let injectableStepperReducer = Reducer<InjectableStepperState, InjectableStepperAction, JourneyEnvironment>.init {
	state, action, _ in
	switch action {
	case .increment:
		if var chosenInj = state.chosenInjection {
			chosenInj.units += state.chosenInjectable.increment
			state.chosenInjection = chosenInj
		} else {
			state.chosenInjectable.increment += state.chosenInjectable.increment
		}
	case .decrement:
		if var chosenInj = state.chosenInjection {
			chosenInj.units -= state.chosenInjectable.increment
			state.chosenInjection = chosenInj
		} else {
			state.chosenInjectable.increment -= state.chosenInjectable.increment
		}
	}
//	func calc(increment: inout Double,
//						activeInjState: inout InjectionsAndActive,
//						action: InjectableStepperAction,
//						injectable: Injectable) {
//		if let activeInjId = activeInjState.activeInjectionId {
//			var activeInj = activeInjState.injections[id: activeInjId]!
//			switch action {
//			case .increment:
//				activeInj.units += increment
//			case .decrement:
//				activeInj.units -= increment
//			}
//			activeInjState.injections[id: activeInjId] = activeInj
//		} else {
//			calc(increment: &increment,
//					 injectable: injectable,
//					 action: action)
//		}
//	}
//
//	func calc(increment: inout Double,
//						injectable: Injectable,
//						action: InjectableStepperAction) {
//		switch action {
//		case .increment:
//			increment += injectable.increment
//		case .decrement:
//			increment -= injectable.increment
//		}
//	}
//
//	switch state.type {
//	case .activeInjections(var injections):
//		calc(increment: &state.injectable.increment,
//				 activeInjState: &injections,
//				 action: action,
//				 injectable: state.injectable)
//		state.type = .activeInjections(injections)
//	case .noInjections(var increment):
//		calc(increment: &increment,
//				 injectable: state.injectable,
//				 action: action)
//		state.type = .noInjections(increment: increment)
//	}
	return .none
}

public struct InjectableStepperState: Equatable {
	var chosenInjection: Injection?
	var chosenInjectable: Injectable
}

public enum InjectableStepperType: Equatable {
	case activeInjections(InjectionsByInjectable)
	case noInjections(increment: Double)
}

public enum InjectableStepperAction: Equatable{
	case increment
	case decrement
}

//	var type: InjectableStepperType
//	var injectable: Injectable
	
//	init(injectable: Injectable) {
//		self.type = .noInjections(increment: injectable.increment)
//		self.injectable = injectable
//	}
//
//	init(usedInjections: InjectionsAndActive,
//			 injectable: Injectable) {
//		self.type = .activeInjections(usedInjections)
//		self.injectable = injectable
//	}

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

struct InjectionStepper: View {
	let store: Store<InjectableStepperState, InjectableStepperAction>
	
	
}

struct InjectableOnlyStepperState: Equatable {
	var injectable: Injectable
	var userIncrement: Double
	init(injectable: Injectable) {
		self.injectable = injectable
		self.userIncrement = injectable.increment
	}
}

struct InjectableOnlyStepper: View {
	let store: Store<InjectableOnlyStepperState, InjectableStepperAction>
	
	struct ViewState: Equatable {
		let title: String
		let color: Color
		let increment: Double
		
		init (state: InjectableOnlyStepperState) {
			self.title = state.injectable.title
			self.color = state.injectable.color
			self.increment = state.userIncrement
		}
	}
	
	var body: some View {
		
	}
}

struct InjectableStepperIncrDecr: View {
	var body: some View {
		HStack {
			Button(action: { viewStore.send(.decrement) },
						 label: { Image(systemName: "minus.rectangle.fill") })
			StepperMiddle
			Button(action: { viewStore.send(.increment )},
						 label: { Image(systemName: "plus.rectangle.fill") })
		}
	}
}

//let chosenInjectionsByInjectable = state.photoInjections.first (where: {
//	$0.injectableId == id
//})!

struct StepperMiddle: View {
	let incrementValue: Double
	let hasActiveInjection: Bool
	var body: some View {
		ZStack {
			if hasActiveInjection {
				InjectableMarkerSimple(increment: String(incrementValue),
															 color: .black)
			} else {
				Text(String(incrementValue)).font(.regular17)
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
