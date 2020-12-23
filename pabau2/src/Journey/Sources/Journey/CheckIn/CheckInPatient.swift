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
//	.init { state, action, env in
//		switch action {
//		case .consents(let id, .complete):
//			let consent = state.consents[id: id]!
//			env.formAPI.post(form: consent,
//							 appointments: state.journey.appointments.map(\.id))
//			break
//		default:
//			break
//		}
//		return .none
//	},
	patientDetailsReducer.pullback(
		state: \CheckInPatientState.patientDetails,
		action: /CheckInPatientAction.patientDetails,
		environment: { $0 }),
	htmlFormReducer.pullback(
		state: \CheckInPatientState.medicalHistory,
		action: /CheckInPatientAction.medicalHistory,
		environment: makeFormEnv(_:)),
	htmlFormReducer.forEach(
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
	let pathway: PathwayTemplate
	var patientDetails: PatientDetails
	var patientDetailsStatus: Bool
	var medicalHistoryId: HTMLFormTemplate.ID
	var medicalHistory: HTMLFormTemplate
	var medicalHistoryStatus: Bool
	var consents: IdentifiedArray<HTMLFormTemplate.ID, HTMLFormTemplate>
	var consentsStatuses: [HTMLFormTemplate.ID: Bool]
	var isPatientComplete: Bool
	var selectedIdx: Int
	var patientDetailsLS: LoadingState
	var medHistoryLS: LoadingState
	var consentsLS: [HTMLFormTemplate.ID: LoadingState]
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
	
	var consentsStates: [JourneyFormInfo<HTMLFormTemplate>] {
		get {
			return self.consents.map {
				JourneyFormInfo(id: $0.id,
								 form: $0,
								 status: consentsStatuses[$0.id]!,
								 loadingState: consentsLS[$0.id]!)
			}
		}
		set {
			newValue.forEach {
				self.consents[id: $0.id] = $0.form
				self.consentsStatuses[$0.id] = $0.status
				self.consentsLS[$0.id] = $0.loadingState
			}
		}
	}
	
	var medHistoryState: JourneyFormInfo<HTMLFormTemplate> {
		get {
			JourneyFormInfo(id: medicalHistoryId,
							 form: medicalHistory,
							 status: medicalHistoryStatus,
							 loadingState: medHistoryLS)
		}
		set {
			self.medicalHistory = newValue.form
			self.medicalHistoryStatus = newValue.status
			self.medHistoryLS = newValue.loadingState
		}
	}

	var patientDetailsState: JourneyFormInfo<PatientDetails> {
		get {
			JourneyFormInfo(id: journey.clientId,
							 form: patientDetails,
							 status: patientDetailsStatus,
							 loadingState: patientDetailsLS)
		}
		set {
			self.patientDetails = newValue.form
			self.patientDetailsStatus = newValue.status
			self.patientDetailsLS = newValue.loadingState
		}
	}
}

public enum CheckInPatientAction {
	case patientDetailsRequests(JourneyFormRequestsAction<PatientDetails>)
	case patientDetails(PatientDetailsAction)
	case medicalHistoryRequests(JourneyFormRequestsAction<HTMLFormTemplate>)
	case medicalHistory(HTMLFormAction)
	case consents(id: HTMLFormTemplate.ID, action: HTMLFormAction)
	case consentsRequests(id: HTMLFormTemplate.ID, action: JourneyFormRequestsAction<HTMLFormTemplate>)
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
		JourneyFormRequests(store: store.scope(state: { $0.patientDetailsState },
											   action: { .patientDetailsRequests($0) }),
							content: { PatientDetailsForm(store:
															store.scope(state: { $0.patientDetails},
																		action: { .patientDetails($0) })
							) })
	case .medicalhistory:
		JourneyFormRequests(store: store.scope(state: { $0.medHistoryState },
											   action: { .medicalHistoryRequests($0) }),
							content: {
								ListHTMLForm(store: store.scope(state: { $0.medicalHistory },
																action: { .medicalHistory($0) })
								) })
	case .consents:
		ForEachStore(store.scope(state: { $0.consents },
								 action: CheckInPatientAction.consents(id: action:)),
					 content: ListHTMLForm.init(store:)
		)
	case .patientComplete:
		PatientCompleteForm(store: store.scope(state: { $0.isPatientComplete }, action: { .patientComplete($0)})
		)
	default:
		fatalError()
	}
}
