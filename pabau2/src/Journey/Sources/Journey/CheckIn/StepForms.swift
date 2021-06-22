import Model
import ComposableArchitecture
import SwiftUI

public let stepFormsReducer: Reducer<[StepState], StepsActions, JourneyEnvironment> =
	stepFormReducer.forEach(
		state: \[StepState].self,
		action: /StepsActions.steps,
		environment: { $0 }
	)

public enum StepsActions: Equatable {
	case steps(idx: Int, action: StepAction)
}

struct StepForms: View {
	
	let store: Store<[StepState], StepsActions>
	
	var body: some View {
		ForEachStore(store.scope(state: { $0 },
								 action: { .steps(idx: $0.0, action: $0.1)}),
					 id: \StepState.id,
					 content: StepForm.init(store:))
	}
}
