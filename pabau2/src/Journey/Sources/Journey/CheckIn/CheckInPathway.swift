import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util
import SharedComponents

struct CheckInPathway: View {
    let store: Store<CheckInPathwayState, CheckInPathwayAction>
    
    var body: some View {
        WithViewStore(store.scope(state: { $0.appointment})) { viewStore in
            CheckInForms(store: store.scope(
                            state: { $0.checkIn },
                            action: { .stepsView($0) }),
                         avatarView: {
                            JourneyProfileView(style: JourneyProfileViewStyle.short,
                                               viewState: .init(appointment: viewStore.state))
                         },
                         content: {
                            StepForms(store: store.scope(state: { $0.stepStates },
                                                         action: { .steps($0) })
                            )
                         }
            )
        }
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
        
        if case .steps(.steps(_, let stepAction)) = action,
           stepAction.isForNextStep() {
            if let nextPendingIndex = state.nextPendingIndex() {
                state.selectedIdx = nextPendingIndex
            }
        }
        return .none
    }
)

public struct CheckInPathwayState: Equatable {
    init(appointment: Appointment, pathway: Pathway, pathwayTemplate: PathwayTemplate, stepStates: [StepState]) {
        self.appointment = appointment
        self.pathway = pathway
        self.pathwayTemplate = pathwayTemplate
        self.stepStates = stepStates
        self.selectedIdx = stepStates.firstIndex(where: { $0.status == .pending }) ?? 0
    }
    
    let appointment: Appointment
    let pathway: Pathway
    let pathwayTemplate: PathwayTemplate
    public var stepStates: [StepState]
    var selectedIdx: Int
    
    func nextPendingIndex() -> Int? {
        let pendingIndexes = stepStates.enumerated().filter {
            $0.element.status == .pending
        }.map{$0.offset}
        if let next = pendingIndexes.first(where: { $0 > selectedIdx }) {
            return next
        } else {
            return pendingIndexes.first
        }
    }
    
    func shouldNavigateAwayFromCheckIn(_ stepAction: StepAction, _ index: Int) -> Bool {
        return stepAction.isForNextStep() && nextPendingIndex() == nil
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
}
