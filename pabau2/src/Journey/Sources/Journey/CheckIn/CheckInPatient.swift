import SwiftUI
import ComposableArchitecture
import Model
import Form
import Util
import CoreDataModel
import SharedComponents

struct CheckInPatientContainer: View {
	let store: Store<CheckInLoadedState, CheckInContainerAction>
	var body: some View {
		WithViewStore(store) { viewStore in
			Group {
				CheckInForms(store: store.scope(
							state: { $0.patientCheckIn.checkIn },
							action: { .patient(.stepsView($0)) }),
						avatarView: {
							JourneyProfileView(style: JourneyProfileViewStyle.short,
											   viewState: .init(appointment: viewStore.state.appointment))
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
	patientDetailsParentReducer.pullback(
		state: \CheckInPatientState.patientDetails,
		action: /CheckInPatientAction.patientDetails,
		environment: { $0 }),
	htmlFormParentReducer.forEach(
		state: \CheckInPatientState.medicalHistories,
		action: /CheckInPatientAction.medicalHistories(id:action:),
		environment: makeFormEnv(_:)),
	htmlFormParentReducer.forEach(
		state: \CheckInPatientState.consents,
		action: /CheckInPatientAction.consents(id:action:),
		environment: makeFormEnv(_:)),
	patientCompleteReducer.pullback(
		state: \CheckInPatientState.isPatientComplete,
		action: /CheckInPatientAction.patientComplete,
		environment: makeFormEnv(_:)),
	CheckInReducer().reducer.pullback(
		state: \CheckInPatientState.checkIn,
		action: /CheckInPatientAction.stepsView,
        environment: { FormEnvironment($0.formAPI, $0.userDefaults, $0.repository) }
	)
)

struct CheckInPatientState: Equatable {
	let appointment: Appointment
	let pathway: PathwayTemplate
	var patientDetails: PatientDetailsParentState
	var medicalHistories: IdentifiedArrayOf<HTMLFormParentState>
	var consents: IdentifiedArrayOf<HTMLFormParentState>
	var isPatientComplete: StepStatus
	var selectedIdx: Int
}

// MARK: - CheckInState
extension CheckInPatientState {
	
	var checkIn: CheckInState {
		get {
			CheckInState(
				selectedIdx: self.selectedIdx,
				stepForms: self.stepForms()
			)
		}
		set {
			self.selectedIdx = newValue.selectedIdx
		}
	}
	
	func steps() -> [Step] {
		return pathway.steps.filter { step in
			return filterBy(.patient)(step.stepType)
		}
	}

	func stepForms() -> [StepFormInfo] {
		return steps().map {
			getForms($0.stepType)
		}.flatMap { $0 }
	}

	func getForms(_ stepType: StepType) -> [StepFormInfo] {
		switch stepType {
		case .patientdetails:
			return [StepFormInfo(status: patientDetails.stepStatus,
								 title: "PATIENT DETAILS")]
		case .medicalhistory:
			return medicalHistories.map {
				StepFormInfo(status: $0.status,
							 title: $0.templateName)
			}
		case .consents:
			return consents.map {
				StepFormInfo(status: $0.status,
							 title: $0.templateName)
			}
		case .patientComplete:
			return [StepFormInfo(status: isPatientComplete,
								 title: "COMPLETE PATIENT")]
		default:
			return []
		}
	}
}

public enum CheckInPatientAction: Equatable {
	case patientDetails(PatientDetailsParentAction)
	case medicalHistories(id: HTMLForm.ID, action: HTMLFormAction)
	case consents(id: HTMLForm.ID, action: HTMLFormAction)
	case patientComplete(PatientCompleteAction)
	case stepsView(CheckInAction)
	//	case footer(FooterButtonsAction)
}

@ViewBuilder
func patientForms(store: Store<CheckInPatientState, CheckInPatientAction>) -> some View {
	ForEach(ViewStore(store).state.steps(),
			content: { patientForm(step: $0, store: store).modifier(FormFrame()) })
}

@ViewBuilder
func patientForm(step: Step,
				 store: Store<CheckInPatientState, CheckInPatientAction>) -> some View {
	switch step.stepType {
	case .patientdetails:
		PatientDetailsParent(store:
							store.scope(state: { $0.patientDetails},
										action: { .patientDetails($0) })
		)
	case .medicalhistory:
		ForEachStore(store.scope(state: { $0.medicalHistories },
								 action: CheckInPatientAction.medicalHistories(id: action:)),
					 content: { HTMLFormParent.init(store: $0) }
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
