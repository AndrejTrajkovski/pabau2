import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util
import SharedComponents

struct CheckInPathway: View {
    let store: Store<CheckInPathwayState, CheckInPathwayAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            CheckInForms(store: store.scope(
                            state: { $0.checkIn },
                            action: { .stepsView($0) }),
                         avatarView: {
                            JourneyProfileView(style: JourneyProfileViewStyle.short,
                                               viewState: .init(appointment: viewStore.state.appointment))
                         },
                         content: {
                            StepForms(store: store.scope(state: { $0.stepStates },
                                                         action: { .steps($0) })
                            )
                         }
            )
        }.debug("CheckInPathway")
    }
}

let checkInPathwayReducer: Reducer<CheckInPathwayState, CheckInPathwayAction, JourneyEnvironment> = .combine(
    
    stepFormsReducer.pullback(
        state: \CheckInPathwayState.stepStates,
        action: /CheckInPathwayAction.steps,
        environment: { $0 }),
    
    CheckInReducer().reducer.pullback(
        state: \CheckInPathwayState.checkIn,
        action: /CheckInPathwayAction.stepsView,
        environment: { FormEnvironment($0.formAPI, $0.userDefaults, $0.repository) }
    ),
    
    .init { state, action, _ in
        
        func nextStep() {
            if state.selectedIdx < state.stepStates.count - 1 {
                state.selectedIdx += 1
            }
        }
        
        switch action {
        case .steps(.steps(_, .stepType(let stepTypeAction))):
            if stepTypeAction.isStepCompleteAction {
                nextStep()
            }
        case .steps(.steps(_, .gotSkipResponse(.success))):
            nextStep()
        default:
            break
        }
        return .none
    }
)

public struct CheckInPathwayState: Equatable {
    let appointment: Appointment
    let pathway: Pathway
    let pathwayTemplate: PathwayTemplate
    public var stepStates: [StepState]
    var selectedIdx: Int
    
    var isOnLastStep: Bool {
        stepStates.count == selectedIdx + 1
    }
}

// MARK: - CheckInState
extension CheckInPathwayState {
    
    var checkIn: CheckInState {
        get {
            CheckInState(
                selectedIdx: self.selectedIdx,
                stepForms: stepStates.map { $0.info() }
            )
        }
        set {
            self.selectedIdx = newValue.selectedIdx
        }
    }
}

public enum CheckInPathwayAction: Equatable {
    case steps(StepsActions)
    case patientComplete(PatientCompleteAction)
    case stepsView(CheckInAction)
    //    case footer(FooterButtonsAction)
}
