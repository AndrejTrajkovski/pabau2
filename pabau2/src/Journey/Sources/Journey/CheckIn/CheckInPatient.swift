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
