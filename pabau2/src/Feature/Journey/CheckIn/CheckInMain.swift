import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture

public enum CheckInMainAction {
	case stepForms(StepFormsAction)
	case complete
	case topView(TopViewAction)
}

struct CheckInMain: View {
	let store: Store<CheckInViewState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<CheckInViewState, CheckInMainAction>
	init (store: Store<CheckInViewState, CheckInMainAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
//		WithViewStore(store) { _ in
			VStack (alignment: .center, spacing: 0) {
				TopView(store: self.store
					.scope(state: { $0.topView },
								 action: { .topView($0) }))
				CheckInBody(store: self.store.scope(
					state: { $0 },
					action: { .stepForms($0) }))
				Spacer()
			}
//		}
	}
}

public enum StepFormsAction {
	case toPatientMode
	case didSelectFormIndex(Int)
	case updateForm(Indexed<UpdateFormAction>)
	case didSelectCompleteFormIdx(Int)
}

public enum UpdateFormAction: Equatable {
	case patientComplete(PatientCompleteAction)
	case didUpdateTemplate(FormTemplate)
	case patientDetails(PatientDetailsAction)
}

let metaFormAndStatusReducer: Reducer<MetaFormAndStatus, UpdateFormAction, JourneyEnvironment> =
	metaFormReducer.pullback(
		state: \MetaFormAndStatus.form,
		action: /UpdateFormAction.self,
		environment: { $0 }
)

let metaFormReducer: Reducer<MetaForm, UpdateFormAction, JourneyEnvironment> =
	Reducer.combine(
		Reducer.init { state, action, _ in
			switch action {
			//FIXME: GO WITH REDUX FOR TEMPLATES
			case .didUpdateTemplate(let template):
				state = MetaForm.init(template)
			default:
				break
			}
			return .none
		},
		patientCompleteReducer.pullbackCp(
			state: /MetaForm.patientComplete,
			action: /UpdateFormAction.patientComplete,
			environment: { $0 }),
		patientDetailsReducer.pullbackCp(
			state: /MetaForm.patientDetails,
			action: /UpdateFormAction.patientDetails,
			environment: { $0 })
)

let checkInBodyReducer = Reducer<CheckInViewState, StepFormsAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didSelectFormIndex(let idx):
		state.selectedIndex = idx
	case .updateForm:
		break
	case .didSelectCompleteFormIdx(let idx):
		state.forms[idx].isComplete = true
		if state.selectedIndex + 1 < state.forms.count {
			state.selectedIndex += 1
		}
	case .toPatientMode:
		break//handled in navigationReducer
	}
	return .none
}

struct CheckInBody: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	let store: Store<CheckInViewState, StepFormsAction>
	@ObservedObject var viewStore: ViewStore<CheckInViewState, StepFormsAction>

	init(store: Store<CheckInViewState, StepFormsAction>) {
		print("check in body init")
		self.store = store
		self.viewStore = ViewStore(store)
	}

	var body: some View {
		print("check in main body")
		return GeometryReader { geo in
			VStack(spacing: 8) {
				StepsCollectionView(steps: self.viewStore.state.forms,
														selectedIdx: self.viewStore.state.selectedIndex) {
															self.viewStore.send(.didSelectFormIndex($0))
				}
				.frame(height: 80)
				Divider()
					.frame(width: geo.size.width)
					.shadow(color: Color(hex: "C1C1C1"), radius: 4, y: 2)
				IfLetStore(self.store
					.scope(state: { $0.selectedForm?.form },
								 action: { .updateForm(Indexed(self.viewStore.state.selectedIndex, $0))
					}), then: PabauFormWrap.init(store:))
					.padding(.bottom,
									 self.keyboardHandler.keyboardHeight > 0 ? self.keyboardHandler.keyboardHeight : 32)
					.padding([.leading, .trailing, .top], 32)
				Spacer()
				if self.keyboardHandler.keyboardHeight == 0 &&
					!self.viewStore.state.isOnCompleteStep {
					FooterButtons(store: self.store)
					.frame(maxWidth: 500)
					.padding(8)
				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
		}
	}
}

struct FooterButtons: View {
	let store: Store<CheckInViewState, StepFormsAction>
	struct State: Equatable {
		let isOnCheckPatient: Bool
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
				NextButton(store: self.store).frame(maxWidth: 250)
			}
		}
	}
}

extension FooterButtons.State {
	init(state: CheckInViewState) {
		self.isOnCheckPatient = {
			guard let selectedForm = state.selectedForm else { return false }
			return stepType(form: selectedForm.form) == .checkpatient
		}()
	}
}

struct NextButton: View {
	let store: Store<CheckInViewState, StepFormsAction>
	struct State: Equatable {
		let index: Int
		let isDisabled: Bool
	}

	var body: some View {
		print("next button body")
		return WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })) { viewStore in
			PrimaryButton(Texts.next, isDisabled: viewStore.state.isDisabled) {
				viewStore.send(.didSelectCompleteFormIdx(viewStore.state.index))
			}
			.disabled(viewStore.state.isDisabled)
		}
	}
}

extension NextButton.State {
	init (state: CheckInViewState) {
		print("next button init")
		self.index = state.selectedIndex
		self.isDisabled = !(state.selectedForm?.form.canProceed ?? true)
	}
}
