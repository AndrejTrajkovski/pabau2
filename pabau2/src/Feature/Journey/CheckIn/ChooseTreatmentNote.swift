import SwiftUI
import ComposableArchitecture
import Util

struct ChooseTreatmentNote: View {
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<CheckInContainerState, CheckInContainerAction>
	init (store: Store<CheckInContainerState, CheckInContainerAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		VStack {
			ChooseFormList(store: store.scope(state: { $0.chooseTreatments },
																				action: { .chooseTreatments($0)}),
										 mode: .treatmentNotes)
			NavigationLink.emptyHidden(self.viewStore.state.isDoctorSummaryActive,
																 DoctorSummary(store: self.store)
																	.navigationBarTitle(Texts.summary)
																	.navigationBarHidden(self.viewStore.state.isDoctorCheckInMainActive)
			)
		}
	}
}
