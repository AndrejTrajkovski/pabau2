import SwiftUI
import ComposableArchitecture
import Util

struct CompletBtnState {
	var selectedForm: MetaFormAndStatus?
	var selectedIndex: Int
}

struct CompleteFormBtn: View {
	let store: Store<CompletBtnState, FooterButtonsAction>
	struct State: Equatable {
		let index: Int
		let isDisabled: Bool
		let btnTitle: String
	}

	var body: some View {
		WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })
		) { viewStore in
			PrimaryButton(viewStore.state.btnTitle,
										isDisabled: viewStore.state.isDisabled) {
											viewStore.send(.didSelectCompleteFormIdx(viewStore.state.index))
			}
		}
	}
}

extension CompleteFormBtn.State {
	init (state: CompletBtnState) {
		self.index = state.selectedIndex
		if let selectedForm = state.selectedForm {
			self.isDisabled = !selectedForm.form.canProceed
			if case .checkPatient = selectedForm.form {
				self.btnTitle = Texts.patientDetailsOK
			} else if case .photos = selectedForm.form {
				self.btnTitle = Texts.completePhotos
			} else {
				self.btnTitle = Texts.completeForm
			}
		} else {
			self.isDisabled = true
			self.btnTitle = ""
		}
	}
}
