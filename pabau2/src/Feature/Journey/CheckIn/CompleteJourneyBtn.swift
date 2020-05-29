import Util
import SwiftUI
import ComposableArchitecture

public enum CompleteJourneyBtnAction {
	case onCompleteJourney
}

struct DoctorSummaryCompleteBtn: View {
	let store: Store<[MetaFormAndStatus], CompleteJourneyBtnAction>
	struct State: Equatable {
		let isBtnDisabled: Bool
	}
	var body: some View {
		WithViewStore(store.scope(
			state: State.init(state:), action: { $0 })) { viewStore in
				CompleteJourneyBtn(isBtnDisabled: viewStore.state.isBtnDisabled,
													 action: { viewStore.send(.onCompleteJourney) })
		}
	}
}

struct CompleteJourneyBtn: View {
	let isBtnDisabled: Bool
	let action: () -> Void
	var body: some View {
		PrimaryButton(Texts.completeJourney,
									isDisabled: isBtnDisabled,
									action)
	}
}

extension DoctorSummaryCompleteBtn.State {
	init(state: [MetaFormAndStatus]) {
		self.isBtnDisabled = !state.allSatisfy { $0.isComplete }
	}
}
