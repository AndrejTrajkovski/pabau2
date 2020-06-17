import SwiftUI
import ComposableArchitecture
import Util
import Overture

struct FooterButtonsState {
	let forms: [MetaFormAndStatus]
	let selectedIndex: Int
	let selectedForm: MetaFormAndStatus?
}

extension FooterButtonsState {
	var completeBtn: CompletBtnState {
		get { CompletBtnState(selectedForm: selectedForm,
													selectedIndex: selectedIndex)}
		set { }
	}
}

struct FooterButtons: View {
	let store: Store<FooterButtonsState, CheckInBodyAction>
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
