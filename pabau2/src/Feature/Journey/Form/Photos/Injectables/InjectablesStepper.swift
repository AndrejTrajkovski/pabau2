import SwiftUI
import ComposableArchitecture

public let injectablesToolStepperReducer = Reducer<InjectablesToolState, InjectablesStepperAction, JourneyEnvironment>.init {
	state, action, _ in

	var chosenInjectable = state.allInjectables[id: state.chosenInjectableId]!
	switch action {
	case .increment:
		chosenInjectable.runningIncrement += chosenInjectable.increment
	case .decrement:
		chosenInjectable.runningIncrement -= chosenInjectable.increment
	}
	
	state.allInjectables[id: state.chosenInjectableId] = chosenInjectable

	if let chosenInjectionId = state.chosenInjectionId {
		state.photoInjections[state.chosenInjectableId]?[id: chosenInjectionId]?.units = chosenInjectable.runningIncrement
	}
	return .none
}

public enum InjectablesStepperAction: Equatable {
	case increment
	case decrement
}

struct InjectablesStepper: View {
	
	let store: Store<InjectablesToolState, InjectablesStepperAction>
	struct State: Equatable {
		let color: Color
		let number: Double
		let hasActiveInjection: Bool
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			VStack {
				InjectablesToolNumber(number: viewStore.state.number,
															color: viewStore.state.color,
															hasActiveInjection: viewStore.state.hasActiveInjection)
				HStack {
					Button(action: { viewStore.send(.decrement) },
								 label: {
									Image("ico-journey-upload-photos-minus")
										.frame(width: 50, height: 50)
					})
					Button(action: { viewStore.send(.increment )},
								 label: {
									Image("ico-journey-upload-photos-plus")
										.frame(width: 50, height: 50)
					})
				}
			}
		}
	}
}

extension InjectablesStepper.State {
  init(state: InjectablesToolState) {
		let injectable = state.allInjectables[id: state.chosenInjectableId]!
		self.color = injectable.color
		if let chosenInjectionId = state.chosenInjectionId,
			let injections = state.photoInjections[state.chosenInjectableId],
			injections.contains(where: { $0.id == state.chosenInjectionId}) {
			let total = injections.reduce(into: TotalInjAndUnits.init(), { res, element in
				res.totalUnits += element.units
				res.totalInj += 1
			})
			self.hasActiveInjection = true
			self.number = injections.first(where: { $0.id == chosenInjectionId})?.units ?? 0
		} else {
			self.hasActiveInjection = false
			self.number = injectable.runningIncrement
		}
	}
}
