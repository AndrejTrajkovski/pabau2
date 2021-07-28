import Form
import Model
import ComposableArchitecture
import SwiftUI
import Util

public let stepBodyReducer: Reducer<StepBodyState, StepBodyAction, JourneyEnvironment> = .combine(
    patientDetailsParentReducer.pullback(
        state: /StepBodyState.patientDetails,
        action: /StepBodyAction.patientDetails,
        environment: makeFormEnv(_:)
    ),
    htmlFormStepContainerReducer.pullback(
        state: /StepBodyState.htmlForm,
        action: /StepBodyAction.htmlForm,
        environment: makeFormEnv(_:)
    ),
    checkPatientDetailsReducer.pullback(
        state: /StepBodyState.timeline,
        action: /StepBodyAction.checkPatientDetails,
        environment: makeFormEnv(_:)
    )
    
//    patientCompleteReducer.pullback(
//        state: \CheckInPatientState.isPatientComplete,
//        action: /CheckInPatientAction.patientComplete,
//        environment: makeFormEnv(_:)),
    )

public enum StepBodyState: Equatable {
    case patientDetails(PatientDetailsParentState)
    case htmlForm(HTMLFormStepContainerState)
    case photos(PhotosState)
    case aftercare(Aftercare)
    case timeline(CheckPatientDetailsState)
    case lab
    case video
    
    init(stepAndEntry: StepAndStepEntry, clientId: Client.ID, pathway: Pathway, appId: Appointment.ID) {
        if stepAndEntry.step.stepType.isHTMLForm {
            let htmlFormState = HTMLFormStepContainerState(stepId: stepAndEntry.step.id,
                                                           stepEntry: stepAndEntry.entry!,
                                                           clientId: clientId,
                                                           pathwayId: pathway.id,
                                                           appointmentId: appId,
                                                           canSkip: stepAndEntry.step.canSkip)
            self = .htmlForm(htmlFormState)
        } else {
            switch stepAndEntry.step.stepType {
            case .patientdetails:
                self = .patientDetails(PatientDetailsParentState(id: stepAndEntry.step.id,
                                                                 pathwayId: pathway.id,
                                                                 clientId: clientId,
                                                                 appointmentId: appId,
                                                                 canSkip: stepAndEntry.step.canSkip)
                )
            case .aftercares:
                self = .aftercare(Aftercare.mock(id: stepAndEntry.step.id))
            case .timeline:
                self = .timeline(CheckPatientDetailsState(id: stepAndEntry.step.id, clientBuilder: nil, patForms: []))
            case .photos:
                self = .photos(PhotosState(id: stepAndEntry.step.id))
            case .lab:
                self = .lab
            case .video:
                self = .video
            default:
                fatalError()
            }
        }
    }
}

public enum StepBodyAction: Equatable {
    
    case patientDetails(PatientDetailsParentAction)
    case htmlForm(HTMLFormStepContainerAction)
    case checkPatientDetails(CheckPatientDetailsAction)
    
    public var isStepCompleteAction: Bool {
        switch self {
        case .patientDetails(.gotPOSTResponse(.success)):
            return true
        case .htmlForm(.chosenForm(.gotPOSTResponse(.success))):
            return true
        case .checkPatientDetails(.gotCompleteResponse(.success)):
            return true
        default:
            return false
        }
    }
}

struct StepBody: View {
    
    let store: Store<StepBodyState, StepBodyAction>
    
    var body: some View {
        SwitchStore(store) {
            CaseLet(state: /StepBodyState.patientDetails, action: StepBodyAction.patientDetails, then: PatientDetailsParent.init(store:))
            CaseLet(state: /StepBodyState.htmlForm, action: StepBodyAction.htmlForm, then: HTMLFormStepContainer.init(store:))
            CaseLet(state: /StepBodyState.timeline, action: StepBodyAction.checkPatientDetails, then: CheckPatientDetails.init(store:))
            Default { EmptyView ()}
        }.modifier(FormFrame())
    }
}
