import SwiftUI
import ComposableArchitecture
import Util
import Overture
import Form
import Model

public let footerButtonsReducer = Reducer<FooterButtonsState, FooterButtonsAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
	case .didSelectCompleteFormIdx(let stepType, let idx):
		state.forms.forms[id: stepType]?.forms[idx].isComplete = true
		state.forms.next()
	case .toPatientMode:
	break//handled in navigationReducer
	case .photos:
	break//handled in navigationReducer
	case .completeJourney:
		break//
	}
	return .none
}

public struct FooterButtonsState {
	var forms: Forms
	let journeyMode: JourneyMode
}

public enum FooterButtonsAction {
	case photos(AddOrEditPhotosBtnAction)
	case didSelectCompleteFormIdx(StepType, Int)
	case toPatientMode
	case completeJourney(CompleteJourneyBtnAction)
}

struct FooterButtons: View {
	let store: Store<FooterButtonsState, FooterButtonsAction>
	struct State: Equatable {
		let isOnCheckPatient: Bool
		let isOnLastDoctorStep: Bool
		let isCompleteJourneyBtnDisabled: Bool
		let isOnPhotosStep: Bool
	}
	var body: some View {
		WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 }
		)) { viewStore in
			HStack {
				if viewStore.state.isOnCheckPatient {
					SecondaryButton(Texts.toPatientMode) {
												viewStore.send(.toPatientMode)
					}
				} else if viewStore.state.isOnPhotosStep {
					AddOrEditPhotosBtn(
						store: self.store.scope(
							state: {
								extract(case: MetaForm.photos,
												from: $0.forms.selectedForm.form)?.selectedIds.isEmpty ?? false },
							action: { .photos($0) }
						)
					)
				}
				CompleteFormBtn(store:
					self.store.scope(state: { $0.forms }))
					.frame(maxWidth: 250)
				if viewStore.state.isOnLastDoctorStep {
					CompleteJourneyBtn(isBtnDisabled: viewStore.state.isCompleteJourneyBtnDisabled,
														 action: {
															viewStore.send(.completeJourney(.onCompleteJourney))
					})
				}
			}
		}
	}
}

extension FooterButtons.State {
	init(state: FooterButtonsState) {
		self.isOnCheckPatient = state.forms.selectedStep == .checkpatient
		self.isOnPhotosStep = state.forms.selectedStep == .photos
		let flatForms = state.forms.forms.flatMap(\.forms)
		let isLastStep = state.forms.selectedStep == state.forms.forms.elements.last?.stepType &&
			state.forms.selectedForm == flatForms.last
		self.isOnLastDoctorStep = state.journeyMode == .doctor && isLastStep
		let canSelectedFormBeCompleted = state.forms.selectedForm.form.canProceed
		let areRestOfFormsComplete = flatForms.prefix(upTo: flatForms.count - 1).allSatisfy(\.isComplete)
		self.isCompleteJourneyBtnDisabled = !(self.isOnLastDoctorStep && canSelectedFormBeCompleted && areRestOfFormsComplete)
	}
}

//if viewStore.state.isCompleteJourneyBtn {
//	CompleteJourneyBtn(isBtnDisabled: viewStore.state.isDisabled,
//										 action: {
//											viewStore.send(.completeJourney(.onCompleteJourney))
//	})
//}
//let isCompleteJourneyBtn: Bool
