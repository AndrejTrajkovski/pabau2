import Form
import Model
import ComposableArchitecture
import SwiftUI

public let stepFormReducer: Reducer<StepState, StepAction, JourneyEnvironment> = .combine(
	patientDetailsParentReducer.pullback(
		state: /StepState.patientDetails,
		action: /StepAction.patientDetails,
		environment: { $0 }),
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
			return  html.id
		}
	}
	
	case patientDetails(PatientDetailsParentState)
	case htmlForm(HTMLFormStepContainerState)
	
	func info() -> StepFormInfo {
		switch self {
		case .htmlForm(let formState):
			return StepFormInfo(status: formState.stepEntry.status, title: formState.stepEntry.stepType.rawValue.uppercased())
		case .patientDetails(let pdState):
			return StepFormInfo(status: pdState.stepStatus, title: "PATIENT DETAILS")
		}
	}
	
	init(stepEntry: StepEntry, stepId: Step.ID, clientId: Client.ID, pathway: Pathway) {
		if stepEntry.stepType.isHTMLForm {
			let htmlFormState = HTMLFormParent
		} else {
			switch stepEntry.stepType {
			case .aftercares, .checkpatient, .patientComplete, .patientdetails, .photos:
				
			default:
				fatalError()
		}
	}
}

public enum StepAction: Equatable {
	case patientDetails(PatientDetailsParentAction)
	case htmlForm(HTMLFormStepContainerAction)
}

struct StepForm: View {
	
	let store: Store<StepState, StepAction>
	
	var body: some View {
		SwitchStore(store) {
			CaseLet(state: /StepState.patientDetails, action: StepAction.patientDetails, then: PatientDetailsParent.init(store:))
			CaseLet(state: /StepState.htmlForm, action: StepAction.htmlForm, then: HTMLFormStepContainer.init(store:))
		}
	}
}
