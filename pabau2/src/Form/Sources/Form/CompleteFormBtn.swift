import SwiftUI
import ComposableArchitecture
import Util
import Model

//protocol CompleteFormBtnState {
//	var canProceed: Bool { get }
//}
//
//enum CompleteFormBtnAction {
//	case complete
//}
//
//struct CompleteFormBtn: View {
//	let store: Store<CompleteFormBtnState, CompleteFormBtnAction>
//}

//struct CompleteFormBtn: View {
//	let store: Store<Forms, FooterButtonsAction>
//	struct State: Equatable {
//		let index: Int
//		let isDisabled: Bool
//		let btnTitle: String
//		let shouldShowButton: Bool
//		let stepType: StepType
//	}
//
//	var body: some View {
//		WithViewStore(store.scope(
//			state: State.init(state:),
//			action: { $0 })
//		) { viewStore in
//			if viewStore.state.shouldShowButton {
//				PrimaryButton(viewStore.state.btnTitle,
//											isDisabled: viewStore.state.isDisabled) {
//												viewStore.send(
//													.didSelectCompleteFormIdx(
//														viewStore.state.stepType, viewStore.state.index)
//												)
//				}
//			} else {
//				EmptyView()
//			}
//		}
//	}
//}

//extension CompleteFormBtn.State {
//	init (state: Forms) {
//		self.stepType = state.selectedStep
//		self.index = state.selectedStepForms.selFormIndex
//		if let selectedForm = state.selectedForm {
//			self.isDisabled = !selectedForm.form.canProceed
//			if case .checkPatient = selectedForm.form {
//				self.btnTitle = Texts.patientDetailsOK
//			} else if case .photos = selectedForm.form {
//				self.btnTitle = Texts.completePhotos
//			} else {
//				self.btnTitle = Texts.completeForm
//			}
//			if case .patientComplete = selectedForm.form {
//				self.shouldShowButton = false
//			} else {
//				self.shouldShowButton = true
//			}
//		} else {
//			self.btnTitle = ""
//			self.shouldShowButton = false
//			self.isDisabled = true
//		}
//	}
//}

public protocol CompleteBtnState {
	var canProceed: Bool { get }
	var title: String { get }
}

public enum CompleteBtnAction {
	case onTap
}

struct CompleteButton<State>: View where State: Equatable & CompleteBtnState {
	let store: Store<State, CompleteBtnAction>
	public var body: some View {
		WithViewStore(store) { viewStore in
			PrimaryButton(viewStore.title,
						  isDisabled: !viewStore.canProceed) {
				viewStore.send(.onTap)
			}
		}
	}
}

extension HTMLFormTemplate: CompleteBtnState {
	public var canProceed: Bool {
		self.formStructure.canProceed
	}
	
	public var title: String {
		self.name
	}
}

extension PatientDetails: CompleteBtnState {
	public var title: String {
		"PATIENT DETAILS"
	}
}
