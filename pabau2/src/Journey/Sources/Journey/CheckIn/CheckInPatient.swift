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
								StepForms(store: store.scope(state: { $0.patientStepStates },
															 action: { .patient(.steps($0)) })
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
	var stepStates: [StepState]
	var selectedIdx: Int
}

// MARK: - CheckInState
extension CheckInPatientState {
	
	var checkIn: CheckInState {
		get {
			CheckInState(
				selectedIdx: self.selectedIdx,
				stepForms: stepStates.map { $0.info() }
			)
		}
		set {
			self.selectedIdx = newValue.selectedIdx
		}
	}
}

public enum CheckInPatientAction: Equatable {
	case steps(StepsActions)
	case patientComplete(PatientCompleteAction)
	case stepsView(CheckInAction)
	//	case footer(FooterButtonsAction)
}
