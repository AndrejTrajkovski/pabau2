import SwiftUI
import ComposableArchitecture

public enum InjectablesToolAction: Equatable {
	case stepper(InjectablesStepperAction)
	case anglePicker(InjectablesAnglePickerAction)
}

struct InjectablesToolEditor: View {

	let store: Store<InjectablesToolState, InjectablesToolAction>

	var body: some View {
		HStack {
			InjectablesStepper(
				store: self.store.scope(state: { $0 },
																action: { .stepper($0) }
				)
			)
			IfLetStore(
				self.store.scope(state: { $0.anglePicker },
												 action: { .anglePicker($0)}),
				then: InjectablesAnglePicker.init(store:),
				else: Text("Add or select an injection to rotate.").layoutPriority(0)
			)
		}
	}
}
