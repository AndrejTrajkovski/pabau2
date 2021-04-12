import SwiftUI
import ComposableArchitecture
import Util
import Model

struct ChooseTreatmentNote: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInContainerAction>
	init (store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: {
			State.init(isDoctorSummaryActive: $0.isDoctorSummaryActive,
								 isDoctorCheckInMainActive: $0.isDoctorCheckInMainActive,
								 appointment: $0.appointment)
		}))
	}

	struct State: Equatable {
		let isDoctorSummaryActive: Bool
		let isDoctorCheckInMainActive: Bool
		let appointment: Appointment
	}

	var body: some View {
		VStack {
			ChooseFormJourney(store: store.scope(state: { $0.chooseTreatments },
												 action: { .chooseTreatments($0)}),
							  appointment: self.viewStore.state.appointment)
			NavigationLink.emptyHidden(self.viewStore.state.isDoctorSummaryActive,
									   EmptyView()
//									   DoctorSummary(store:
//														self.store.scope(state: { $0 }, action: { $0 })
//									   ).hideNavBar(viewStore.state.isDoctorCheckInMainActive,
//													Texts.summary)
//									   .navigationBarBackButtonHidden(true)
			)
		}
	}
}
