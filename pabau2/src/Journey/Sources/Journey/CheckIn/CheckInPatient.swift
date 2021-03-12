import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util

struct CheckInPatientContainer: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			Group {
				CheckIn(store: store.scope(
							state: { $0.patientCheckIn },
							action: { .patient(.stepsView($0)) }),
						avatarView: {
							JourneyProfileView(style: .short,
											   viewState: .init(journey: viewStore.state.journey))
						},
						content: {
							patientForms(store:
											store.scope(state: { $0.patientCheckIn },
														action: { .patient($0) }
											)
							)
						}
				)
				handBackDeviceLink(viewStore.state.isHandBackDeviceActive)
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
	htmlFormParentReducer.pullback(
		state: \CheckInPatientState.medicalHistory,
		action: /CheckInPatientAction.medicalHistory,
		environment: makeFormEnv(_:)),
	htmlFormParentReducer.forEach(
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
		environment: { FormEnvironment($0.formAPI, $0.userDefaults) }
	)
)

struct CheckInPatientState: Equatable, CheckInState {
	let journey: Journey
	let pathway: PathwayTemplate
	var patientDetails: ClientBuilder
	var patientDetailsStatus: Bool
	var medicalHistoryId: HTMLForm.ID
	var medicalHistory: HTMLFormParentState
	var consents: IdentifiedArrayOf<HTMLFormParentState>
	var isPatientComplete: Bool
	var selectedIdx: Int
	var patientDetailsLS: LoadingState
}

// MARK: - CheckInState
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
			return [StepFormInfo(status: medicalHistory.isComplete,
								 title: "MEDICAL HISTORY")]
		case .consents:
			return consents.map {
				StepFormInfo(status: $0.isComplete,
							 title: $0.info.name)
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
	case medicalHistory(HTMLFormAction)
	case consents(id: HTMLForm.ID, action: HTMLFormAction)
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
		PatientDetailsForm(store:
							store.scope(state: { $0.patientDetails},
										action: { .patientDetails($0) })
		)
	case .medicalhistory:
		HTMLFormParent(store: store.scope(state: { $0.medicalHistory },
										  action: { .medicalHistory($0) })
		)
	case .consents:
		ForEachStore(store.scope(state: { $0.consents },
								 action: CheckInPatientAction.consents(id: action:)),
					 content: { HTMLFormParent.init(store: $0) }
		)
	case .patientComplete:
		PatientCompleteForm(store: store.scope(state: { $0.isPatientComplete }, action: { .patientComplete($0)})
		)
	default:
		fatalError()
	}
}
