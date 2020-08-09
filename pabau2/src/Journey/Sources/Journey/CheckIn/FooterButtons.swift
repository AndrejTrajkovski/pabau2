import SwiftUI
import ComposableArchitecture
import Util
import Overture
import Form

public let footerButtonsReducer = Reducer<FooterButtonsState, FooterButtonsAction, JourneyEnvironment>.init { state, action, _ in
	switch action {
		case .didSelectCompleteFormIdx(let idx):
			state.forms[idx].isComplete = true
			goToNextStep(&state.stepsState)
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
	var forms: [MetaFormAndStatus]
	var selectedIndex: Int
	var selectedForm: MetaFormAndStatus?

	var stepsState: StepsViewState {
		get {
			StepsViewState(selectedIndex: selectedIndex,
										 forms: forms)
		}
		set {
			self.selectedIndex = newValue.selectedIndex
			self.forms = newValue.forms
		}
	}
}

public enum FooterButtonsAction {
	case photos(AddOrEditPhotosBtnAction)
	case didSelectCompleteFormIdx(Int)
	case toPatientMode
	case completeJourney(CompleteJourneyBtnAction)
}

extension FooterButtonsState {
	var completeBtn: CompletBtnState {
		get { CompletBtnState(selectedForm: selectedForm,
													selectedIndex: selectedIndex)}
		set { }
	}
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
												from: $0.selectedForm?.form)?.selectedIds.isEmpty ?? false },
							action: { .photos($0) }
						)
					)
				}
				CompleteFormBtn(store:
					self.store.scope(state: { $0.completeBtn }))
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
		self.isOnCheckPatient = {
			guard let selectedForm = state.selectedForm else { return false }
			return stepType(form: selectedForm.form) == .checkpatient
		}()
		self.isOnPhotosStep = {
			guard let selectedForm = state.selectedForm else { return false }
			return stepType(form: selectedForm.form) == .photos
		}()
		let isDoctorMode = state.forms.map(pipe(get(\.form), stepType(form:))).allSatisfy(with(.doctor, filterBy))
		let isLastIndex = state.selectedIndex == state.forms.count - 1
		self.isOnLastDoctorStep = isDoctorMode && isLastIndex
		let canSelectedFormBeCompleted: Bool = {
			guard let selectedForm = state.selectedForm else { return false }
			return selectedForm.form.canProceed
			}()
		let areRestOfFormsComplete = state.forms.prefix(upTo: state.forms.count - 1).allSatisfy(\.isComplete)
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
