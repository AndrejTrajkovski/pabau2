import Model
import ComposableArchitecture
import SwiftUI

public let stepFormsReducer: Reducer<[StepState], StepsActions, JourneyEnvironment> =
	stepFormReducer.forEach(
		state: \[StepState].self,
		action: /StepsActions.steps,
		environment: { $0 }
	)

public enum StepsActions: Equatable {
	case steps(idx: Int, action: StepAction)
}

struct StepForms: View {
	
	let store: Store<[StepState], StepsActions>
	
	var body: some View {
		ForEachStore(store.scope(state: { $0 },
								 action: { .steps(idx: $0.0, action: $0.1)}),
					 id: \StepState.id,
					 content: StepForm.init(store:))
	}
}

//	func getForm(idx: Int, stepId: Step.Id, stepEntry: StepEntry, formAPI: FormAPI, clientId: Client.ID) -> Effect<StepAction, Never>? {
//
//		if stepEntry.stepType.isHTMLForm {
//			guard let formTemplateId = stepEntry.htmlFormInfo?.templateIdToLoad else { return nil }
//			return getHTMLForm(formTemplateId: formTemplateId)
//				.map {
//					StepAction.htmlForm(.htmlForm(HTMLFormAction.gotForm($0)))
//				}
//		} else {
//			switch stepEntry.stepType {
//			case .patientdetails:
//				return formAPI.getPatientDetails(clientId: clientId)
//					.map(ClientBuilder.init(client:))
//					.catchToEffect()
//					.map(PatientDetailsParentAction.gotGETResponse)
//					.map(StepAction.patientDetails)
//			case .checkpatient:
//				return nil
//			case .photos:
//				return nil
//			case .aftercares:
//				return nil
//			case .patientComplete:
//				return nil
//			default:
//				return nil
//			}
//		}
//	}
//
//	func getForms(formAPI: FormAPI) -> Effect<CheckInPatientAction, Never> {
//		let getPatientHTMLForms = pathway.orderedPatientSteps().compactMap {
//			getForm(stepId: $0.key, stepEntry: $0.value, formAPI: formAPI, clientId: appointment.customerId)
//		}
//	}
