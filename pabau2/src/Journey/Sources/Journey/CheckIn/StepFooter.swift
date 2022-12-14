import Model
import SwiftUI
import ComposableArchitecture
import Form
import Util

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
                    then: PatientDetailsCompleteBtn.init(store:)
            )
            CaseLet(state: /StepBodyState.htmlForm, action: StepBodyAction.htmlForm,
                    then: HTMLFormPathwayCompleteBtn.init(store:)
            )
            CaseLet(state: /StepBodyState.timeline, action: StepBodyAction.checkPatientDetails,
                    then: CheckPatientDetailsFooter.init(store:)
            )
            CaseLet(state: /StepBodyState.aftercare, action: StepBodyAction.aftercare,
                    then: AftercareCompleteBtn.init(store:))
            CaseLet(state: /StepBodyState.photos, action: StepBodyAction.photos,
                    then: PhotosCompleteBtn.init(store:))
            Default { EmptyView () }
        }
    }
}

struct PhotosCompleteBtn: View {
    let store: Store<PhotosState, PhotosFormAction>
    
    struct State: Equatable {
        let shouldShowEditPhotos: Bool
        let isEditButtonDisabled: Bool
        
        init(state: PhotosState) {
            self.shouldShowEditPhotos = !state.photos.isEmpty
            self.isEditButtonDisabled = state.selectedIds.isEmpty
        }
    }
    
    var body: some View {
        WithViewStore(store.scope(state: State.init(state:))) { viewStore in
            Group {
                PrimaryButton(Texts.editPhotos,
                              isDisabled: viewStore.isEditButtonDisabled,
                              { viewStore.send(.didSelectEditPhotos) }
                )
                PrimaryButton(Texts.addPhotos,
                              isDisabled: false,
                              { viewStore.send(.didSelectAddPhotos) }
                )
            }
        }
    }
}

struct AftercareCompleteBtn: View {
    let store: Store<AftercareState, AftercareAction>
    var body: some View {
        WithViewStore(store) { viewStore in
            CompleteButton(canComplete: true,
                           onComplete: {
                            viewStore.send(.complete)
            })
        }
    }
}

struct CheckPatientDetailsFooter: View {
    
    let store: Store<CheckPatientDetailsState, CheckPatientDetailsAction>
    @ObservedObject var viewStore: ViewStore<Void, CheckPatientDetailsAction>
    
    init(store: Store<CheckPatientDetailsState, CheckPatientDetailsAction>) {
        self.store = store
        self.viewStore = ViewStore(store.stateless)
    }
    
    var body: some View {
        Group {
            PrimaryButton(Texts.toPatientMode,
                          isDisabled: false,
                          { viewStore.send(.backToPatientMode) }
            )
            CompleteButton(canComplete: true,
                           onComplete: { viewStore.send(.complete) }
            )
        }
    }
}

struct HTMLFormPathwayCompleteBtn: View {
    
    let store: Store<HTMLFormStepContainerState, HTMLFormStepContainerAction>
    
    var body: some View {
        IfLetStore(store.scope(state: { $0.chosenForm?.form },
                               action: { .chosenForm(.rows($0)) }),
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
