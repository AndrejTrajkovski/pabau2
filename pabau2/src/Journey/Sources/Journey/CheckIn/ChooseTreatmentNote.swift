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
								 journey: $0.journey)
		}))
	}

	struct State: Equatable {
		let isDoctorSummaryActive: Bool
		let isDoctorCheckInMainActive: Bool
		let journey: Journey
	}

	var body: some View {
		VStack {
			ChooseFormJourney(store: store.scope(state: { $0.chooseTreatments },
												 action: { .chooseTreatments($0)}),
							  mode: .treatmentNotes,
							  journey: self.viewStore.state.journey)
			NavigationLink.emptyHidden(self.viewStore.state.isDoctorSummaryActive,
									   DoctorSummary(store:
														self.store.scope(state: { $0 }, action: { $0 })
									   ).hideNavBar(viewStore.state.isDoctorCheckInMainActive,
													Texts.summary)
									   .navigationBarBackButtonHidden(true)
			)
		}
	}
}
