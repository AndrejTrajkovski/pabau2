import Model
import ComposableArchitecture
import SwiftUI
import Util

public let stepFormsReducer: Reducer<[StepState], StepsActions, JourneyEnvironment> =

    .combine(
        stepReducer.forEach(
            state: \[StepState].self,
            action: /StepsActions.steps,
            environment: { $0 }
        ),
        .init { state, action, _ in

            func updateAftercareSteps(_ photos: [SavedPhoto]) {
                var toUpdate = [Int: StepState]()
                state.indices.forEach { idx in
                    guard case StepType.aftercares = state[idx].stepType else { return }
                    var aftercareStep = state[idx]
                    guard case StepBodyState.aftercare(var aftercareBody) = aftercareStep.stepBody else { return }
                    photos.forEach {
                        aftercareBody.images.append($0)
                    }
                    aftercareStep.stepBody = .aftercare(aftercareBody)
                    toUpdate[idx] = aftercareStep
                }
                toUpdate.forEach {
                    state[$0.key] = $0.value
                }
            }

            if case StepsActions.steps(_, .stepType(.photos(.gotStepPhotos(.success(let photos))))) = action {
                updateAftercareSteps(photos)
            }
            
            if case StepsActions.steps(_, .stepType(.photos(.editPhoto(.saveResponse(_, .success(let photos)))))) = action {
                updateAftercareSteps([photos])
            }

            return .none
        }
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
                VStack(spacing: 32) {
                    Text("No forms here").font(.subheadline)
                    PrimaryButton("Complete", { viewStore.send(.noStepsComplete) })
                }
            }
        }
	}
}
