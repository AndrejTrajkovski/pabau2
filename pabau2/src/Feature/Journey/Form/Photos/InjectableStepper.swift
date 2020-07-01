import SwiftUI
import ComposableArchitecture

public let injectableStepperReducer = Reducer<InjectableStepperState, InjectableStepperAction, JourneyEnvironment>.init {
	state, action, _ in
	var chosenInjectable = state.allInjectables[id: state.chosenInjectableId]!
	if let chosenInjectionId = state.chosenInjectionId,
		var injections = state.photoInjections[state.chosenInjectableId] {
		var injectionIdx = injections.firstIndex(where: {
			$0.id == chosenInjectionId
		})!
		switch action {
		case .increment:
			injections[injectionIdx].units += chosenInjectable.runningIncrement
		case .decrement:
			injections[injectionIdx].units -= chosenInjectable.runningIncrement
		}
		state.photoInjections[state.chosenInjectableId] = injections
	} else {
		switch action {
		case .increment:
			chosenInjectable.runningIncrement += chosenInjectable.increment
		case .decrement:
			chosenInjectable.runningIncrement -= chosenInjectable.increment
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
		let chosenInjectableId: InjectableId
		let chosenInjectionId: UUID?
	}
	
	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			VStack {
				Divider()
				HStack {
					InjectableStepperTop(title: viewStore.state.injTitle,
															 description: viewStore.state.desc,
															 color: viewStore.state.color)
					Spacer()
					HStack {
						Button(action: { viewStore.send(.decrement) },
									 label: {
										Image(systemName: "minus.rectangle.fill")
										.frame(width: 50, height: 50)
						})
						ZStack {
							if viewStore.state.hasActiveInjection {
								InjectableMarkerSimple(increment: String(viewStore.state.number),
																			 color: .black)
							} else {
								Text(String(viewStore.state.number)).font(.regular17)
							}
						}.frame(width: 50, height: 50)
						Button(action: { viewStore.send(.increment )},
									 label: {
										Image(systemName: "plus.rectangle.fill")
										.frame(width: 50, height: 50)
						})
					}
				}
			}
		}
	}
}

struct InjectableStepperTop: View {
	let title: String
	let description: String
	let color: Color
	
	var body: some View {
		VStack(alignment: .leading) {
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
		self.chosenInjectableId = injectable.id
		self.chosenInjectionId = state.chosenInjectionId
		self.color = injectable.color
		self.injTitle = injectable.title
		if let chosenInjectionId = state.chosenInjectionId,
			let injections = state.photoInjections[state.chosenInjectableId] {
			let total = injections.reduce(into: TotalInjAndUnits.init(), { res, element in
				res.totalUnits += element.units
				res.totalInj += 1
			})
			self.hasActiveInjection = true
			self.desc = "Selection: \(total.totalInj) injections - \(total.totalUnits)"
			self.number = injections.first(where: { $0.id == chosenInjectionId})?.units ?? 0
		} else {
			self.hasActiveInjection = false
			self.desc = ""
			self.number = injectable.runningIncrement
		}
	}
}
