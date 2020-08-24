import SwiftUI
import ComposableArchitecture
import Util
import Form
import Model

struct CompletBtnState {
	let forms: Forms
}

struct CompleteFormBtn: View {
	let store: Store<CompletBtnState, FooterButtonsAction>
	struct State: Equatable {
		let index: Int
		let isDisabled: Bool
		let btnTitle: String
		let shouldShowButton: Bool
		let stepType: StepType
	}

	var body: some View {
		WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })
		) { viewStore in
			if viewStore.state.shouldShowButton {
				PrimaryButton(viewStore.state.btnTitle,
											isDisabled: viewStore.state.isDisabled) {
												viewStore.send(
													.didSelectCompleteFormIdx(
														viewStore.state.stepType, viewStore.state.index)
												)
				}
			} else {
				EmptyView()
			}
		}
	}
}

extension CompleteFormBtn.State {
	init (state: CompletBtnState) {
		self.stepType = state.forms.selectedStep
		self.index = state.forms.selectedStepForms.selFormIndex
//		if let selectedForm = state.forms.selectedForm {
		let selectedForm = state.forms.selectedForm
		self.isDisabled = !selectedForm.form.canProceed
		if case .checkPatient = selectedForm.form {
			self.btnTitle = Texts.patientDetailsOK
		} else if case .photos = selectedForm.form {
			self.btnTitle = Texts.completePhotos
		} else {
			self.btnTitle = Texts.completeForm
		}
		if case .patientComplete = selectedForm.form {
			self.shouldShowButton = false
		} else {
			self.shouldShowButton = true
		}
//		} else {
//			self.isDisabled = true
//			self.btnTitle = ""
//			self.shouldShowButton = false
//		}
	}
}
