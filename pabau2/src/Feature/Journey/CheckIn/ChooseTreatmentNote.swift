import SwiftUI
import ComposableArchitecture
import Util

struct ChooseTreatmentNote: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInContainerAction>
	init (store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(state: {
			State.init(isDoctorSummaryActive: $0.isDoctorSummaryActive,
								 isDoctorCheckInMainActive: $0.isDoctorCheckInMainActive)
		}))
	}

	struct State: Equatable {
		var isDoctorSummaryActive: Bool
		var isDoctorCheckInMainActive: Bool
	}

	var body: some View {
		VStack {
			ChooseFormList(store: store.scope(state: { $0.chooseTreatments },
																				action: { .chooseTreatments($0)}),
										 mode: .treatmentNotes)
			NavigationLink.emptyHidden(self.viewStore.state.isDoctorSummaryActive,
																 DoctorSummary(store:
																	self.store.scope(state: { $0 }, action: { $0 })
																).hideNavBar(viewStore.state.isDoctorCheckInMainActive,
																						 Texts.summary)
			)
		}
	}
}
