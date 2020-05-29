import SwiftUI
import ComposableArchitecture
import Util

struct CompletBtnState {
	var selectedForm: MetaFormAndStatus?
	var selectedIndex: Int
}

struct CompleteFormBtn: View {
	let store: Store<CompletBtnState, CheckInBodyAction>
	struct State: Equatable {
		let index: Int
		let isDisabled: Bool
	}

	var body: some View {
		WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })
		) { viewStore in
			PrimaryButton(Texts.completeForm,
										isDisabled: viewStore.state.isDisabled) {
											viewStore.send(.didSelectCompleteFormIdx(viewStore.state.index))
			}
		}
	}
}

extension CompleteFormBtn.State {
	init (state: CompletBtnState) {
		print("next button init")
		self.index = state.selectedIndex
		self.isDisabled = !(state.selectedForm?.form.canProceed ?? true)
	}
}
