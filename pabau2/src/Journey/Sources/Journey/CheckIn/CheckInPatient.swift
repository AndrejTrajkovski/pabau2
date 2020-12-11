import SwiftUI
import ComposableArchitecture
import Model
import Form

struct CheckInPatientContainer: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store.scope(state: { $0.isHandBackDeviceActive }).actionless) { viewStore in
			CheckInPatient(store: store.scope(
							state: { $0.patientCheckIn },
							action: { .patient($0) })
			).navigationBarTitle("")
			 .navigationBarHidden(true)
			handBackDeviceLink(viewStore.state)
		}
	}
	
	func handBackDeviceLink(_ active: Bool) -> some View {
		NavigationLink.emptyHidden(active,
								   HandBackDevice(
									store: self.store.scope(
										state: { $0 },
										action: { $0 }
									)
								   )
								   .navigationBarTitle("")
								   .navigationBarHidden(true)
		)
	}
}

let checkInPatientReducer: Reducer<CheckInPatientState, CheckInPatientAction, JourneyEnvironment> = .combine(
	patientDetailsReducer.pullback(
		state: \CheckInPatientState.patientDetails,
		action: /CheckInPatientAction.patientDetails,
		environment: { $0 }),
	formTemplateReducer.pullback(
		state: \CheckInPatientState.medicalHistory,
		action: /CheckInPatientAction.medicalHistory,
		environment: { $0 }),
	formTemplateReducer.forEach(
		state: \CheckInPatientState.consents,
		action: /CheckInPatientAction.consents(idx:action:),
		environment: { $0 }),
	patientCompleteReducer.pullback(
		state: \CheckInPatientState.isPatientComplete,
		action: /CheckInPatientAction.patientComplete,
		environment: { $0 })
	//	topViewReducer.pullback(
	//		state: \CheckInViewState.self,
	//		action: /CheckInMainAction.topView,
	//		environment: { $0 })
)

struct CheckInPatientState: Equatable, StepsViewState {
	let journey: Journey
	let pathway: Pathway
	var patientDetails: PatientDetails
	var patientDetailsStatus: Bool
	var medicalHistory: FormTemplate
	var medicalHistoryStatus: Bool
	var consents: IdentifiedArrayOf<FormTemplate>
	var consentsStatuses: [FormTemplate.ID: Bool]
	var isPatientComplete: Bool
	var patientSelectedIndex: Int
	
	var forms: [MetaFormAndStatus] {
		return pathway.steps.map(\.stepType).filter(filterBy(.patient)).map {
			getForms($0)
		}.flatMap { $0 }
	}

	var selectedIdx: Int {
		get { patientSelectedIndex }
		set { patientSelectedIndex = newValue }
	}
	
	func getForms(_ stepType: StepType) -> [MetaFormAndStatus] {
		switch stepType {
		case .patientdetails:
			return [MetaFormAndStatus(patientDetails, patientDetailsStatus)]
		case .medicalhistory:
			return [MetaFormAndStatus(medicalHistory, medicalHistoryStatus)]
		case .consents:
			return consents.map {
				MetaFormAndStatus($0, consentsStatuses[$0.id]!)
			}
		case .patientComplete:
			return [MetaFormAndStatus(PatientComplete(), isPatientComplete)]
		default:
			return []
		}
	}
}

public enum CheckInPatientAction {
	case patientDetails(PatientDetailsAction)
	case medicalHistory(FormTemplateAction)
	case consents(idx: Int, action: FormTemplateAction)
	case patientComplete(PatientCompleteAction)
	case stepsView(StepsViewAction)
	case topView(TopViewAction)
//	case footer(FooterButtonsAction)
}

struct CheckInPatient: View {
	
	let store: Store<CheckInPatientState, CheckInPatientAction>
	var body: some View {
		VStack (spacing: 0) {
			TopView(store: self.store
						.scope(state: { $0 },
							   action: { .topView($0) }))
			CheckInBody(store: self.store.scope(
							state: { $0 },
							action: { .stepsView($0) }))
			Spacer()
		}
	}
	
	@ViewBuilder
	func selectedForm(_ state: CheckInPatientState) -> some View {
		switch state.selectedForm().form {
		case is PatientDetails:
			PatientDetailsForm(store: store.scope(state: { $0.patientDetails }, action: { .patientDetails($0) }
			))
		case let medH as FormTemplate where medH.formType == .history:
			ListDynamicForm(store: store.scope(state: { $0.medicalHistory }, action: { .medicalHistory($0) }
			))
		default:
			EmptyView()
		}
	}
}
