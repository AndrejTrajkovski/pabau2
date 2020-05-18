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
		WithViewStore(store) { _ in
			VStack (alignment: .center, spacing: 0) {
				TopView(store: self.store
					.scope(state: { $0.topView },
								 action: { .topView($0) }))
				CheckInBody(store: self.store.scope(
					state: { $0 },
					action: { .stepForms($0) }))
				Spacer()
			}
		}
	}
}

public enum StepFormsAction {
	case didSelectNextForm
	case didSelectFormIndex(Int)
	case childForm(Indexed<ChildFormAction>)
}

public enum ChildFormAction {
	case patientComplete(PatientCompleteAction)
	case didUpdateTemplate(FormTemplate)
	case didUpdatePatientDetails(PatientDetails)
	case didFinishTemplate(MetaFormAndStatus)
	case didFinishPatientDetails(PatientDetails)
}

let anyFormReducer: Reducer<MetaFormAndStatus, ChildFormAction, JourneyEnvironment> = (
	.combine (
		Reducer { state, action, _ in
			switch action {
			case .didFinishPatientDetails:
				break
			case .didUpdateTemplate(let template):
				state = .init(.template(template), state.isComplete)
			case .didUpdatePatientDetails:
				break
			case .didFinishTemplate(let template):
				state.isComplete = true
			case .patientComplete(_):
				break
			}
			return .none
		},
		metaFormReducer.pullback(
			state: \MetaFormAndStatus.form,
			action: /ChildFormAction.self,
			environment: { $0 }
		)
	)
)

let metaFormReducer: Reducer<MetaForm, ChildFormAction, JourneyEnvironment> =
	Reducer.combine(
		patientCompleteReducer.pullbackCp(
			state: /MetaForm.patientComplete,
			action: /ChildFormAction.patientComplete,
			environment: { $0 })
)

let checkInBodyReducer = Reducer<CheckInViewState, StepFormsAction, JourneyEnvironment> { state, action, _ in
	switch action {
	case .didSelectFormIndex(let idx):
		state.selectedIndex = idx
	case .childForm:
		break
	case .didSelectNextForm:
		if state.forms.count > state.selectedIndex + 1 {
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
					.scope(state: { $0.selectedForm },
								 action: { .childForm(Indexed(self.viewStore.state.selectedIndex, $0))
					}))
					.padding(.bottom, self.keyboardHandler.keyboardHeight > 0 ? self.keyboardHandler.keyboardHeight : 32)
					.padding([.leading, .trailing, .top], 32)
				Spacer()
				if self.keyboardHandler.keyboardHeight == 0 &&
					!self.viewStore.state.isOnCompleteStep {
					BigButton(text: Texts.next) {
						self.viewStore.send(.didSelectNextForm)
						self.viewStore.send(.childForm(
							Indexed<ChildFormAction>(self.viewStore.state.selectedIndex,
																				.didFinishTemplate(self.viewStore.state.forms[self.viewStore.state.selectedIndex]))))
					}
					.frame(width: 230)
					.padding(8)
				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
		}
	}
}
