import Model
import ComposableArchitecture
import SwiftUI
import Util

public let stepFormsReducer: Reducer<[StepState], StepsActions, JourneyEnvironment> =
	stepReducer.forEach(
		state: \[StepState].self,
		action: /StepsActions.steps,
		environment: { $0 }
	)

public enum StepsActions: Equatable {
	case steps(idx: Int, action: StepAction)
    case noStepsComplete
}

struct StepForms: View {
	
	let store: Store<[StepState], StepsActions>
	
    var body: some View {
        WithViewStore(store.scope(state: { $0.count > 0 })) { viewStore in
            if viewStore.state {
                ForEachStore(store.scope(state: { $0 },
                                         action: { .steps(idx: $0.0, action: $0.1)}),
                             id: \StepState.id,
                             content: StepFormContainer.init(store:))
            } else {
                VStack {
                    Text("No forms here")
                    PrimaryButton("Complete", { viewStore.send(.noStepsComplete) })
                }
            }
        }
	}
}
