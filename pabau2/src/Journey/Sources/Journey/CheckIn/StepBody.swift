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
    ),
    aftercareReducer.pullback(
        state: /StepBodyState.aftercare,
        action: /StepBodyAction.aftercare,
        environment: makeFormEnv(_:)
    ),
    photosFormReducer.pullback(
        state: /StepBodyState.photos,
        action: /StepBodyAction.photos,
        environment: makeFormEnv(_:)
    )
)

public enum StepBodyState: Equatable {
    case patientDetails(PatientDetailsParentState)
    case htmlForm(HTMLFormStepContainerState)
    case photos(PhotosState)
    case aftercare(AftercareState)
    case timeline(CheckPatientDetailsState)
    case lab
    case video
    
    init(stepAndEntry: StepAndStepEntry, clientId: Client.ID, pathwayId: Pathway.ID, appointmentId: Appointment.ID) {
        
        switch stepAndEntry.step.stepType {
        case .medicalhistory, .consents, .treatmentnotes, .prescriptions:
            let htmlFormState = HTMLFormStepContainerState(stepId: stepAndEntry.step.id,
                                                           stepEntry: stepAndEntry.entry!,
                                                           clientId: clientId,
                                                           pathwayId: pathwayId,
                                                           appointmentId: appointmentId,
                                                           canSkip: stepAndEntry.step.canSkip)
            self = .htmlForm(htmlFormState)
        case .patientdetails:
            self = .patientDetails(PatientDetailsParentState(id: stepAndEntry.step.id,
                                                             pathwayId: pathwayId,
                                                             clientId: clientId,
                                                             appointmentId: appointmentId,
                                                             canSkip: stepAndEntry.step.canSkip)
            )
        case .aftercares:
            self = .aftercare(AftercareState.init(id: stepAndEntry.step.id,
                                                  images: [],
                                                  aftercares: [],
                                                  recalls: []))
        case .timeline:
            self = .timeline(CheckPatientDetailsState(id: stepAndEntry.step.id, clientBuilder: nil, patForms: []))
        case .photos:
            self = .photos(PhotosState(id: stepAndEntry.step.id,
                                       pathwayId: pathwayId,
                                       clientId: clientId))
        case .lab:
            self = .lab
        case .video:
            self = .video
        }
    }
}

public enum StepBodyAction: Equatable {
    
    case patientDetails(PatientDetailsParentAction)
    case htmlForm(HTMLFormStepContainerAction)
    case checkPatientDetails(CheckPatientDetailsAction)
    case aftercare(AftercareAction)
    case photos(PhotosFormAction)
    
    public var isStepCompleteAction: Bool {
        switch self {
        case .patientDetails(.gotPOSTResponse(.success)):
            return true
        case .htmlForm(.chosenForm(.gotPOSTResponse(.success))):
            return true
        case .checkPatientDetails(.gotCompleteResponse(.success)):
            return true
        case .aftercare(.gotCompleteResponse(.success(.completed))):
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
            CaseLet(state: /StepBodyState.aftercare, action: StepBodyAction.aftercare, then: AftercareForm.init(store:))
            CaseLet(state: /StepBodyState.photos, action: StepBodyAction.photos, then: PhotosForm.init(store:))
            Default { EmptyView ()}
        }.modifier(FormFrame())
    }
}
