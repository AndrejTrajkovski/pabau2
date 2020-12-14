import SwiftUI
import ComposableArchitecture
import Model
import Form

struct CheckInPatientContainer: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store.scope(state: { $0.isHandBackDeviceActive }).actionless) { viewStore in
			Group {
				CheckInPatient(store: store.scope(
								state: { $0.patientCheckIn },
								action: { .patient($0) })
				).navigationBarTitle("")
				.navigationBarHidden(true)
				handBackDeviceLink(viewStore.state)
			}
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
		environment: { $0 }),
	StepsViewReducer<CheckInPatientState>().reducer.pullback(
		state: \CheckInPatientState.self,
		action: /CheckInPatientAction.stepsView,
		environment: { $0 }
	)
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

	func stepTypes() -> [StepType] {
		return pathway.steps.map(\.stepType).filter(filterBy(.patient))
	}

	var stepForms: [StepFormInfo] {
		return stepTypes().map {
			getForms($0)
		}.flatMap { $0 }
	}

	var selectedIdx: Int {
		get { patientSelectedIndex }
		set { patientSelectedIndex = newValue }
	}

	func getForms(_ stepType: StepType) -> [StepFormInfo] {
		switch stepType {
		case .patientdetails:
			return [StepFormInfo(status: patientDetailsStatus,
								 title: "PATIENT DETAILS")]
		case .medicalhistory:
			return [StepFormInfo(status: medicalHistoryStatus,
								 title: "MEDICAL HISTORY")]
		case .consents:
			return consents.map {
				StepFormInfo(status: consentsStatuses[$0.id]!,
							 title: $0.name)
			}
		case .patientComplete:
			return [StepFormInfo(status: isPatientComplete,
								title: "COMPLETE PATIENT")]
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
		WithViewStore(store) { viewStore in
			VStack (spacing: 0) {
				TopView(store: self.store
							.scope(state: { $0 },
								   action: { .topView($0) }))
				StepSelector(store: store.scope(state: { $0 },
												action: { .stepsView($0)})
				).frame(height: 80)
				Divider()
					.frame(maxWidth: .infinity)
					.shadow(color: Color(hex: "C1C1C1"), radius: 4, y: 2)
				formsStack(viewStore.state)
					.padding(16)
			}
		}
	}

	@ViewBuilder
	func formsStack(_ state: CheckInPatientState) -> some View {
		GeometryReader { geo in
			ScrollView(.horizontal) {
				HStack {
					ForEach(state.stepTypes(), content: form(stepType:))
//						.padding(64)
						.frame(width: geo.size.width, height: geo.size.height)
				}
			}
		}
	}

	@ViewBuilder
	func form(stepType: StepType) -> some View {
		switch stepType {
		case .patientdetails:
			PatientDetailsForm(store: store.scope(state: { $0.patientDetails },
												  action: { .patientDetails($0) })
			)
		case .medicalhistory:
			ListDynamicForm(store: store.scope(state: { $0.medicalHistory },
											   action: { .medicalHistory($0) })
			)
		case .consents:
			ForEachStore(store.scope(state: { $0.consents },
									 action: CheckInPatientAction.consents(idx: action:)),
						 content: ListDynamicForm.init(store:)
			)
		case .patientComplete:
			PatientCompleteForm(store:
									store.scope(state: { $0.isPatientComplete }, action: { .patientComplete($0)})
			)
		default:
			EmptyView()
		}
	}
}
