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
	patientDetailsParentReducer.pullback(
		state: \CheckInPatientState.patientDetails,
		action: /CheckInPatientAction.patientDetails,
		environment: { $0 }),
	htmlFormStepContainerReducer.forEach(
		state: \CheckInPatientState.htmlForms,
		action: /CheckInPatientAction.htmlForms(id:action:),
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

public struct CheckInPatientState: Equatable {
	let appointment: Appointment
	let pathway: Pathway
	let pathwayTemplate: PathwayTemplate
	var stepStates: IdentifiedArrayOf<StepState>
	var isPatientComplete: StepStatus
	var selectedIdx: Int
}

// MARK: - CheckInState
extension CheckInPatientState {
	
	func getForm(stepId: Step.Id, stepEntry: StepEntry, formAPI: FormAPI, clientId: Client.ID) -> Effect<CheckInPatientAction, Never>? {
		
		if stepEntry.stepType.isHTMLForm {
			guard let formTemplateId = stepEntry.htmlFormInfo?.templateIdToLoad else { return nil }
			return getHTMLForm(formTemplateId: formTemplateId)
				.map {
					CheckInPatientAction.htmlForms(id: stepId, action: .htmlForm(HTMLFormAction.gotForm($0)))
				}
		} else {
			switch stepEntry.stepType {
			case .patientdetails:
				return formAPI.getPatientDetails(clientId: clientId)
					.map(ClientBuilder.init(client:))
					.catchToEffect()
					.map(PatientDetailsParentAction.gotGETResponse)
					.map(CheckInPatientAction.patientDetails)
			case .checkpatient:
				return nil
			case .photos:
				return nil
			case .aftercares:
				return nil
			case .patientComplete:
				return nil
			default:
				return nil
			}
		}
	}
	
	func getForms(formAPI: FormAPI) -> Effect<CheckInPatientAction, Never> {
		let getPatientHTMLForms = pathway.orderedPatientSteps().compactMap {
			getForm(stepId: $0.key, stepEntry: $0.value, formAPI: formAPI, clientId: appointment.customerId)
		}
	}
	
	
	var checkIn: CheckInState {
		get {
			CheckInState(
				selectedIdx: self.selectedIdx,
				stepForms: pathway.orderedPatientSteps().compactMap { getStepFormInfo($0.value) }
			)
		}
		set {
			self.selectedIdx = newValue.selectedIdx
		}
	}
	
	func getStepFormInfo(_ stepEntry: StepEntry) -> StepFormInfo? {
		switch stepEntry.stepType {
		case .patientdetails:
			return StepFormInfo(status: patientDetails.stepStatus,
								title: "PATIENT DETAILS")
		case .medicalhistory:
			return StepFormInfo(status: stepEntry.status,
								title: stepEntry.stepType.rawValue)
		case .consents:
			return StepFormInfo(status: stepEntry.status,
								title: stepEntry.stepType.rawValue)
		case .patientComplete:
			return StepFormInfo(status: isPatientComplete,
								title: "COMPLETE PATIENT")
		default:
			return nil
		}
	}
}

public enum CheckInPatientAction: Equatable {
	case patientDetails(PatientDetailsParentAction)
	case htmlForms(id: Step.ID, action: HTMLFormStepContainerAction)
	case patientComplete(PatientCompleteAction)
	case stepsView(CheckInAction)
	//	case footer(FooterButtonsAction)
}

@ViewBuilder
func patientForms(store: Store<CheckInPatientState, CheckInPatientAction>) -> some View {
	ForEach(ViewStore(store).state.pathway.orderedPatientSteps(),
			id: \.key,
			content: { patientForm(step: $0, store: store).modifier(FormFrame()) })
}

@ViewBuilder
func patientForm(step: Dictionary<Step.ID, StepEntry>.Element,
				 store: Store<CheckInPatientState, CheckInPatientAction>) -> some View {
	if step.value.stepType.isHTMLForm {
		ForEachStore(store.scope(state: { $0.htmlForms },
								 action: CheckInPatientAction.htmlForms(id: action:)),
					 content: { HTMLFormStepContainer.init(store: $0) }
		)
	} else {
		switch step.value.stepType {
		case .patientdetails:
			PatientDetailsParent(store:
								store.scope(state: { $0.patientDetails},
											action: { .patientDetails($0) })
			)
		case .patientComplete:
			PatientCompleteForm(store: store.scope(state: { $0.isPatientComplete }, action: { .patientComplete($0)})
			)
		default:
			fatalError()
		}
	}
}
