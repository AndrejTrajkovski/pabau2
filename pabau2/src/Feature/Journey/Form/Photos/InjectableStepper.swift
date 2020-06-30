import SwiftUI
import ComposableArchitecture

public let injectableStepperReducer = Reducer<InjectableStepperState, InjectableStepperAction, JourneyEnvironment>.init {
	state, action, _ in
	var chosenInjectable = state.allInjectables[id: state.chosenInjectableId]!
	if let chosenInjectionId = state.chosenInjectionId {
		var injections = state.photoInjections[state.chosenInjectableId]!
		var injectionIdx = injections.firstIndex(where: {
			$0.id == chosenInjectionId
		})!
		switch action {
		case .increment:
			injections[injectionIdx].units += chosenInjectable.runningIncrement
		case .decrement:
			injections[injectionIdx].units -= chosenInjectable.runningIncrement
		}
	} else {
		switch action {
		case .increment:
			chosenInjectable.incrementMe()
		case .decrement:
			chosenInjectable.decrementMe()
		}
		state.allInjectables[id: state.chosenInjectableId] = chosenInjectable
	}
	return .none
}

public struct InjectableStepperState: Equatable {
	var allInjectables: IdentifiedArrayOf<Injectable>
	var photoInjections: [InjectableId: [Injection]]
	var chosenInjectableId: InjectableId
	var chosenInjectionId: UUID?
}

public enum InjectableStepperAction: Equatable {
	case increment
	case decrement
}

struct InjectableStepper: View {
	let store: Store<InjectableStepperState, InjectableStepperAction>
	struct State: Equatable {
		let color: Color
		let injTitle: String
		let desc: String
		let number: Double
		let hasActiveInjection: Bool
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			HStack {
				InjectableStepperTop(title: viewStore.state.injTitle,
														 description: viewStore.state.desc,
														 color: viewStore.state.color)
				Spacer()
				HStack {
					Button(action: { viewStore.send(.decrement) },
								 label: { Image(systemName: "minus.rectangle.fill") })
					StepperMiddle(incrementValue: viewStore.state.number,
												hasActiveInjection: viewStore.state.hasActiveInjection)
					Button(action: { viewStore.send(.increment )},
								 label: { Image(systemName: "plus.rectangle.fill") })
				}
			}
		}
	}
}

struct StepperMiddle: View {
	let incrementValue: Double
	let hasActiveInjection: Bool
	var body: some View {
		ZStack {
			if hasActiveInjection {
				InjectableMarkerSimple(increment: String(incrementValue),
															 color: .black)
				.frame(width: 75, height: 75)
			} else {
				Text(String(incrementValue)).font(.regular17)
			}
		}
	}
}

struct InjectableStepperTop: View {
	let title: String
	let description: String
	let color: Color
	
	var body: some View {
		VStack {
			HStack {
				Circle()
					.fill(color)
					.frame(width: 10, height: 10)
				Text(title).font(.medium16)
			}
			Text(description)
		}
	}
}

extension InjectableStepper.State {
  init(state: InjectableStepperState) {
		let injectable = state.allInjectables[id: state.chosenInjectableId]!
		self.color = injectable.color
		self.injTitle = injectable.title
		if let chosenInjectionId = state.chosenInjectionId {
			let injections = state.photoInjections[state.chosenInjectableId]
			let total = injections?.reduce(into: TotalInjAndUnits.init(), { res, element in
				res.totalUnits += element.units
				res.totalInj += 1
			}) ?? TotalInjAndUnits()
			self.hasActiveInjection = true
			self.desc = "Selection: \(total.totalInj) injections - \(total.totalUnits)"
			self.number = injections?.first(where: { $0.id == chosenInjectionId})?.units ?? 0
		} else {
			self.hasActiveInjection = false
			self.desc = ""
			self.number = injectable.runningIncrement
		}
	}
}
