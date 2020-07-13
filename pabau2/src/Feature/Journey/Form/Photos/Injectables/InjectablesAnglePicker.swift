import SwiftUI
import ComposableArchitecture

struct InjectablesAnglePickerState: Equatable {
	var allInjectables: IdentifiedArrayOf<Injectable>
	var photoInjections: [InjectableId: [Injection]]
	var chosenInjectableId: InjectableId
	var chosenInjectionId: UUID
}

let injectablesToolAnglePickerReducer = Reducer<InjectablesAnglePickerState, InjectablesAnglePickerAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didPickAngle(let angle):
		if var injections = state.photoInjections[state.chosenInjectableId],
			let injectionIdx = injections.firstIndex(where: {
				$0.id == state.chosenInjectionId
			}) {
			injections[injectionIdx].angle = angle
			state.photoInjections[state.chosenInjectableId] = injections
		}
	}
	return .none
}

public enum InjectablesAnglePickerAction: Equatable {
	case didPickAngle(Angle)
}

struct InjectablesAnglePicker: View {
	
	let store: Store<InjectablesAnglePickerState, InjectablesAnglePickerAction>
	
	struct ViewState: Equatable {
		let angle: Angle
		let color: Color
	}
	
	var body: some View {
		WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
			AnglePicker(angle: viewStore.binding(
				get: { $0.angle },
				send: { .didPickAngle($0)}
				),
									circleColor: viewStore.state.color,
									selectionColor: .black,
									selectionBorderColor: .red,
									strokeWidth: 20
			)
//				.rotationEffect(.init(degrees: -90))
				.background(Color.blue)
		}
	}
}

extension InjectablesAnglePicker.ViewState {
	init(state: InjectablesAnglePickerState) {
		if let chosenInjection = state.photoInjections[state.chosenInjectableId]?.first(where: {
			$0.id == state.chosenInjectionId
		}), let chosenInjectable = state.allInjectables[id: state.chosenInjectableId] {
			self.color = chosenInjectable.color
			self.angle = chosenInjection.angle
		} else {
			self.color = .white
			self.angle = .zero
		}
	}
}
