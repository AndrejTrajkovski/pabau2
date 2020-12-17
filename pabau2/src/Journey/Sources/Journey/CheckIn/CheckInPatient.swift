import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

struct CheckInPatientContainer: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store.scope(state: { $0.isHandBackDeviceActive }).actionless) { viewStore in
			Group {
				CheckIn(store: store.scope(
							state: { $0.patientCheckIn },
							action: { .patient(.stepsView($0)) }),
						content: {
							patientForms(store:
											store.scope(state: { $0.patientCheckIn },
														action: { .patient($0) }
											)
							)
						}
				)
				handBackDeviceLink(viewStore.state)
			}
		}.debug("CheckInPatientContainer")
	}

	func handBackDeviceLink(_ active: Bool) -> some View {
		NavigationLink.emptyHidden(active,
								   HandBackDevice(store: self.store)
								   .navigationBarTitle("")
								   .navigationBarHidden(true)
		)
	}
}

let checkInPatientReducer: Reducer<CheckInPatientState, CheckInPatientAction, JourneyEnvironment> = .combine(
	.init { state, action, env in
		switch action {
		case .consents(let id, .complete):
			let consent = state.consents[id: id]!
			env.formAPI.post(form: consent,
							 appointments: state.journey.appointments.map(\.id))
			break
		default:
			break
		}
		return .none
	},
	patientDetailsReducer.pullback(
		state: \CheckInPatientState.patientDetails,
		action: /CheckInPatientAction.patientDetails,
		environment: { $0 }),
	formTemplateReducer.pullback(
		state: \CheckInPatientState.medicalHistory,
		action: /CheckInPatientAction.medicalHistory,
		environment: makeFormEnv(_:)),
	formTemplateReducer.forEach(
		state: \CheckInPatientState.consents,
		action: /CheckInPatientAction.consents(id:action:),
		environment: makeFormEnv(_:)),
	patientCompleteReducer.pullback(
		state: \CheckInPatientState.isPatientComplete,
		action: /CheckInPatientAction.patientComplete,
		environment: makeFormEnv(_:)),
	CheckInReducer<CheckInPatientState>().reducer.pullback(
		state: \CheckInPatientState.self,
		action: /CheckInPatientAction.stepsView,
		environment: { $0 }
	)
	//	topViewReducer.pullback(
	//		state: \CheckInViewState.self,
	//		action: /CheckInMainAction.topView,
	//		environment: { $0 })
)

struct CheckInPatientState: Equatable, CheckInState {
	let journey: Journey
	let pathway: Pathway
	var patientDetails: PatientDetails
	var patientDetailsStatus: Bool
	var medicalHistory: FormTemplate
	var medicalHistoryStatus: Bool
	var consents: IdentifiedArrayOf<FormTemplate>
	var consentsStatuses: [FormTemplate.ID: Bool]
	var isPatientComplete: Bool
	var selectedIdx: Int
	var patientDetailsLS: LoadingState
	var medHistoryLS: LoadingState
	var consentsLS: [FormTemplate.Id: LoadingState]
}

//MARK: - CheckInState
extension CheckInPatientState {
	func stepTypes() -> [StepType] {
		return pathway.steps.map(\.stepType).filter(filterBy(.patient))
	}
	
	func stepForms() -> [StepFormInfo] {
		return stepTypes().map {
			getForms($0)
		}.flatMap { $0 }
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
	case consents(id: FormTemplate.ID, action: FormTemplateAction)
	case patientComplete(PatientCompleteAction)
	case stepsView(CheckInAction)
	//	case footer(FooterButtonsAction)
}

@ViewBuilder
func patientForms(store: Store<CheckInPatientState, CheckInPatientAction>) -> some View {
	ForEach(ViewStore(store).state.stepTypes(),
			content: { patientForm(stepType: $0, store: store).modifier(FormFrame()) })
}

@ViewBuilder
func patientForm(stepType: StepType,
				 store: Store<CheckInPatientState, CheckInPatientAction>) -> some View {
	switch stepType {
	case .patientdetails:
		PatientDetailsForm(store: store.scope(state: { $0.patientDetails }, action: { .patientDetails($0) })
		)
	case .medicalhistory:
		ListDynamicForm(store: store.scope(state: { $0.medicalHistory },
										   action: { .medicalHistory($0) })
		)
	case .consents:
		ForEachStore(store.scope(state: { $0.consents },
								 action: CheckInPatientAction.consents(id: action:)),
					 content: ListDynamicForm.init(store:)
		)
	case .patientComplete:
		PatientCompleteForm(store: store.scope(state: { $0.isPatientComplete }, action: { .patientComplete($0)})
		)
	default:
		fatalError()
	}
}
