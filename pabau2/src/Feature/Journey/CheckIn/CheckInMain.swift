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
	}
	return .none
}

struct CheckInBody: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	let store: Store<CheckInViewState, StepFormsAction>
	@ObservedObject var viewStore: ViewStore<CheckInViewState, StepFormsAction>

	init(store: Store<CheckInViewState, StepFormsAction>) {
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
				PabauFormWrap(store: self.store
					.scope(state: { $0.selectedForm.form },
								 action: { .updateForm(Indexed(self.viewStore.state.selectedIndex, $0))
					}))
					.padding(.bottom, self.keyboardHandler.keyboardHeight > 0 ? self.keyboardHandler.keyboardHeight : 32)
					.padding([.leading, .trailing, .top], 32)
				Spacer()
				if self.keyboardHandler.keyboardHeight == 0 &&
					!self.viewStore.state.isOnCompleteStep {
					NextButton(store: self.store)
					.frame(width: 230)
					.padding(8)
				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
		}
	}
}

struct NextButton: View {
	let store: Store<CheckInViewState, StepFormsAction>
	struct State: Equatable {
		let index: Int
		let canProceed: Bool
	}

	var body: some View {
		print("next button body")
		return WithViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })) { viewStore in
			PrimaryButton(text: Texts.next) {
				viewStore.send(.didSelectCompleteFormIdx(viewStore.state.index))
			}
			.disabled(!viewStore.state.canProceed)
			.frame(minWidth: 304, maxWidth: 495)
		}
	}
}

extension NextButton.State {
	init (state: CheckInViewState) {
		print("next button init")
		self.index = state.selectedIndex
		self.canProceed = state.selectedForm.form.canProceed
	}
}
