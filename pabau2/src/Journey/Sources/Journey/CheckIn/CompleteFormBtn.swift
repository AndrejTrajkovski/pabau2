import SwiftUI
import ComposableArchitecture
import Util
import Form
import Model

struct CompleteFormBtn: View {
	let store: Store<Forms, FooterButtonsAction>
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
	init (state: Forms) {
		self.stepType = state.selectedStep
		self.index = state.selectedStepForms.selFormIndex
		let selectedForm = state.selectedForm
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
	}
}
