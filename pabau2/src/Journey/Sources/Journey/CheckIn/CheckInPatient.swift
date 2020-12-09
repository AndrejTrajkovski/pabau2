import SwiftUI
import ComposableArchitecture
import Model

struct CheckInPatient: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		print("CheckInPatientBody")
		return WithViewStore(store.scope(state: { $0.isHandBackDeviceActive },
										 action: { $0 })) { viewStore in
			VStack {
				CheckInMain(store:
								self.store.scope(state: { $0.patientCheckIn },
												 action: { .patient($0) }
								)
				)
				.navigationBarTitle("")
				.navigationBarHidden(true)
				NavigationLink.emptyHidden(viewStore.state,
										   HandBackDevice(
											store: self.store.scope(
												state: { $0 }, action: { $0 }
											)
										   )
										   .navigationBarTitle("")
										   .navigationBarHidden(true)
				)
			}
		}
	}
}

let checkInPatientReducer: Reducer<CheckInPatientState, CheckInBodyAction, JourneyEnvironment> =
	(
	.combine(
		.init { state, action, _ in
			switch action {
			case .stepForms:
				break//binding
			case .stepsView:
				break//handled stepsViewReducer
			case .completeJourney:
				break//handled in checkInMiddleware
			case .footer:
				break//handled footerButtonsReducer
			}
			return .none
		}
//		stepsViewReducer.pullback(
//			state: \.forms,
//			action: /CheckInBodyAction.stepsView,
//			environment: { $0 })
//		)
	)


struct CheckInPatientState: Equatable {
	let patientSteps: [StepType]

	var patientDetails: PatientDetails
	var patientDetailsStatus: Bool

	var medicalHistory: FormTemplate
	var medicalHistoryStatus: Bool

	var consents: [FormTemplate]
	var consentsStatuses: [FormTemplate.ID: Bool]

	var isPatientComplete: Bool
}

public enum CheckInPatientAction {
	case patientDetails(PatientDetailsAction)
	case medicalHistory(FormTemplateAction)
	case consents(idx: Int, action: FormTemplateAction)
	case patientComplete(PatientCompleteAction)
	case stepsView(StepsViewAction)
	case footer(FooterButtonsAction)
}

struct CheckInPatientMain: View {
	
	let store: Store<CheckInViewState, CheckInMainAction>
	var body: some View {
		VStack (spacing: 0) {
			TopView(store: self.store
						.scope(state: { $0 },
							   action: { .topView($0) }))
			CheckInBody(store: self.store.scope(
							state: { $0 },
							action: { .checkInBody($0) }))
			Spacer()
		}
	}
}
