import Form
import Model
import ComposableArchitecture
import SwiftUI

public let stepFormReducer: Reducer<StepState, StepAction, JourneyEnvironment> = .combine(
	patientDetailsParentReducer.pullback(
		state: /StepState.patientDetails,
		action: /StepAction.patientDetails,
		environment: makeFormEnv(_:)),
	htmlFormStepContainerReducer.pullback(
		state: /StepState.htmlForm,
		action: /StepAction.htmlForm,
		environment: makeFormEnv(_:))
	
//	patientCompleteReducer.pullback(
//		state: \CheckInPatientState.isPatientComplete,
//		action: /CheckInPatientAction.patientComplete,
//		environment: makeFormEnv(_:)),
	)

public enum StepState: Equatable, Identifiable {
	public var id: Step.ID {
		switch self {
		case .patientDetails(let pds):
			return pds.id
		case .htmlForm(let html):
			return html.id
		case .photos(let photos):
			return photos.id
		case .aftercare(let aftercare):
			return aftercare.id
		case .checkPatient(let checkPatient):
			return checkPatient.id
		}
	}
	
	case patientDetails(PatientDetailsParentState)
	case htmlForm(HTMLFormStepContainerState)
	case photos(PhotosState)
	case aftercare(Aftercare)
	case checkPatient(CheckPatient)
    
    public var status: StepStatus {
        switch self {
        case .htmlForm(let formState):
            return formState.status
        case .patientDetails(let pdState):
            return pdState.stepStatus
        default:
            return .pending
        }
    }
	
	func info() -> StepFormInfo {
		switch self {
		case .htmlForm(let formState):
			return StepFormInfo(status: formState.status, title: formState.stepType.rawValue.uppercased())
		case .patientDetails(let pdState):
			return StepFormInfo(status: pdState.stepStatus, title: "PATIENT DETAILS")
		default:
			return StepFormInfo(status: StepStatus.pending, title: "TODO")
		}
	}
	
	init(stepAndEntry: StepAndStepEntry, clientId: Client.ID, pathway: Pathway) {
		if stepAndEntry.step.stepType.isHTMLForm {
			let htmlFormState = HTMLFormStepContainerState(stepId: stepAndEntry.step.id,
														   stepEntry: stepAndEntry.entry!,
														   clientId: clientId,
														   pathwayId: pathway.id)
			self = .htmlForm(htmlFormState)
		} else {
			switch stepAndEntry.step.stepType {
			case .patientdetails:
				self = .patientDetails(PatientDetailsParentState(id: stepAndEntry.step.id,
                                                                 pathwayId: pathway.id,
                                                                 clientId: clientId,
                                                                 status: stepAndEntry.entry?.status ?? .pending)
                )
			case .aftercares:
				self = .aftercare(Aftercare.mock(id: stepAndEntry.step.id))
			case .checkpatient:
				self = .checkPatient(CheckPatient(id: stepAndEntry.step.id, clientBuilder: nil, patForms: []))
			case .photos:
				self = .photos(PhotosState(id: stepAndEntry.step.id))
			default:
				fatalError()
			}
		}
	}
}

public enum StepAction: Equatable {
	case patientDetails(PatientDetailsParentAction)
	case htmlForm(HTMLFormStepContainerAction)
    
    public var isStepCompleteAction: Bool {
        switch self {
        case .patientDetails(.gotPOSTResponse(.success)):
            return true
        case .htmlForm(.chosenForm(.gotPOSTResponse(.success))):
            return true
        default:
            return false
        }
    }
}

struct StepForm: View {
	
	let store: Store<StepState, StepAction>
	
	var body: some View {
		SwitchStore(store) {
			CaseLet(state: /StepState.patientDetails, action: StepAction.patientDetails, then: PatientDetailsParent.init(store:))
			CaseLet(state: /StepState.htmlForm, action: StepAction.htmlForm, then: HTMLFormStepContainer.init(store:))
		}.modifier(FormFrame())
	}
}
