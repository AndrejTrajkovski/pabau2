import SwiftUI
import ComposableArchitecture

public enum InjectablesToolAction: Equatable {
	case stepper(InjectablesStepperAction)
	case anglePicker(InjectablesAnglePickerAction)
}

struct InjectablesToolEditor: View {
	
	let store: Store<InjectablesToolState, InjectablesToolAction>
	
	var body: some View {
		WithViewStore(self.store.scope(state: { $0.type })) { viewStore in
			Group {
				if viewStore.state == InjectablesToolType.stepper {
					InjectablesStepper(
						store: self.store.scope(state: { $0 },
																		action: { .stepper($0) }
						)
					)
				} else if viewStore.state == InjectablesToolType.anglePicker {
					IfLetStore(
						self.store.scope(state: { $0.anglePicker },
														 action: { .anglePicker($0)}),
						then: InjectablesAnglePicker.init(store:)
					)
				} else {
					EmptyView()
				}
			}
		}
	}
}
