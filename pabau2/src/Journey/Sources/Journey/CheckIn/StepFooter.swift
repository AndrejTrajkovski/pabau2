import Model
import SwiftUI
import ComposableArchitecture
import Form

struct StepFooter: View {
    let store: Store<StepState, StepAction>
    
    var body: some View {
        HStack {
            SkipStepButton(store: store)
            CompleteButtonType(store: store.scope(state: { $0.stepBody }, action: { .stepType($0) }))
        }.padding([.leading, .trailing])
    }
}

struct CompleteButtonType: View {
    let store: Store<StepBodyState, StepBodyAction>
    
    var body: some View {
        SwitchStore(store) {
            CaseLet(state: /StepBodyState.patientDetails,
                    action: StepBodyAction.patientDetails,
                    then: PatientDetailsCompleteBtn.init(store:))
            CaseLet(state: /StepBodyState.htmlForm, action: StepBodyAction.htmlForm,
                    then: HTMLFormPathwayCompleteBtn.init(store:))
            Default { EmptyView () }
        }
    }
}

struct HTMLFormPathwayCompleteBtn: View {
    
    let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    
    var body: some View {
        IfLetStore(store.scope(state: { $0.chosenForm?.form }, action: { .chosenForm(.rows($0)) }),
                   then: HTMLFormCompleteBtn.init(store:),
                   else: { CompleteButton(canComplete: false, onComplete: { }) }
        )
    }
}

struct PatientDetailsCompleteBtn: View {
    let store: Store<PatientDetailsParentState, PatientDetailsParentAction>
    
    struct State: Equatable {
        let canComplete: Bool
        init(state: PatientDetailsParentState) {
            self.canComplete = !(state.patientDetails?.firstName.isEmpty ?? true) && !(state.patientDetails?.lastName.isEmpty ?? true)
                && !(state.patientDetails?.email.isEmpty ?? true)
        }
    }
    
    var body: some View {
        WithViewStore(store.scope(state: State.init(state:))) { viewStore in
            CompleteButton(canComplete: viewStore.canComplete, onComplete: { viewStore.send(.complete) })
        }
    }
}
