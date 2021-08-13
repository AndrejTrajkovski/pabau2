import SwiftUI
import ComposableArchitecture

public struct InjectablesToolState: Equatable {
	var allInjectables: IdentifiedArrayOf<Injectable>
	var photoInjections: [InjectableId: IdentifiedArrayOf<Injection>]
	var chosenInjectableId: InjectableId
	var chosenInjectionId: UUID?
}

public let injectablesToolReducer: Reducer<InjectablesToolState, InjectablesToolAction, FormEnvironment> = .combine(
	injectablesToolStepperReducer.pullback(
		state: \.self,
		action: /InjectablesToolAction.stepper,
		environment: { $0 })
//	injectablesToolAnglePickerReducer.optional().pullback(
//		state: \InjectablesToolState.anglePicker,
//		action: /InjectablesToolAction.anglePicker,
//		environment: { $0 })
)

struct InjectablesTool: View {
	let store: Store<InjectablesToolState, InjectablesToolAction>
	struct State: Equatable {
		let color: Color
		let injTitle: String
		let desc: String
	}

	var body: some View {
		WithViewStore(store.scope(state: State.init(state:))) { viewStore in
			VStack {
				Divider()
				HStack {
					InjectablesToolTitle(title: viewStore.state.injTitle,
															 description: viewStore.state.desc,
															 color: viewStore.state.color)
						.frame(maxWidth: .infinity, alignment: .leading)
					InjectablesToolEditor(store: self.store.scope(state: { $0 }))
					.frame(maxWidth: .infinity)
				}.padding()
			}
		}
	}
}

extension InjectablesTool.State {
  init(state: InjectablesToolState) {
		let injectable = state.allInjectables[id: state.chosenInjectableId]!
		self.color = injectable.color
		self.injTitle = injectable.title
		if let injections = state.photoInjections[state.chosenInjectableId] {
			let total = injections.reduce(into: TotalInjAndUnits.init(), { res, element in
				res.totalUnits += element.units
				res.totalInj += 1
			})
			self.desc = "Total: \(total.totalInj) injections - \(total.totalUnits) units"
		} else {
			self.desc = "Total: 0 injections"
		}
	}
}

//extension InjectablesToolState {
//	var anglePicker: InjectablesAnglePickerState? {
//		get {
//			chosenInjectionId.map {
//				InjectablesAnglePickerState(
//					allInjectables: self.allInjectables,
//					photoInjections: self.photoInjections,
//					chosenInjectableId: self.chosenInjectableId,
//					chosenInjectionId: $0
//				)
//			}
//		}
//		set {
//			guard let newValue = newValue else { return }
//			self.chosenInjectionId = newValue.chosenInjectionId
//			self.allInjectables = newValue.allInjectables
//			self.photoInjections = newValue.photoInjections
//			self.chosenInjectableId = newValue.chosenInjectableId
//		}
//	}
//}
