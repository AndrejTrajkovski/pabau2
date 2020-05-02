import SwiftUI
import Model
import ComposableArchitecture
import Util

public enum CheckInMainAction {
	case closeBtnTap
	case patient(StepFormsAction)
}

struct CheckInMain: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInMainAction>

	init(store: Store<CheckInContainerState, CheckInMainAction>) {
		self.store = store
		self.viewStore = self.store
			.scope(value: State.init(state:),
						 action: { $0 })
			.view
	}

	struct State: Equatable {
		let journey: Journey

		init(state: CheckInContainerState) {
			self.journey = state.journey
		}
	}

	var body: some View {
		print("check in main body")
		return
			VStack (alignment: .center, spacing: 0) {
				ZStack {
					Button.init(action: { self.viewStore.send(.closeBtnTap) }, label: {
						Image(systemName: "xmark")
							.font(Font.light30)
							.foregroundColor(.gray142)
							.frame(width: 30, height: 30)
					})
						.padding()
						.frame(minWidth: 0, maxWidth: .infinity,
									 minHeight: 0, maxHeight: .infinity,
									 alignment: .topLeading)
					Spacer()
					JourneyProfileView(style: .short,
														 viewState: .init(journey: self.viewStore.value.journey))
						.padding()
						.frame(minWidth: 0, maxWidth: .infinity,
									 minHeight: 0, maxHeight: .infinity,
									 alignment: .top)
					Spacer()
					RibbonView(completedNumberOfSteps: 1, totalNumberOfSteps: 4)
						.offset(x: -80, y: -60)
						.frame(minWidth: 0, maxWidth: .infinity,
									 minHeight: 0, maxHeight: .infinity,
									 alignment: .topTrailing)
				}.frame(height: 168.0)
				StepForms(store:
					self.store.scope(
						value: { $0 },
						action: { .patient($0) }))
				Spacer()
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}

public struct PatientDetails: Equatable, Hashable {
}

public struct Aftercare: Equatable, Hashable {
}

public enum MetaForm: Equatable, Hashable {
	case patientDetails(PatientDetails)
	case aftercare(Aftercare)
	case template(FormTemplate)
	var title: String {
		switch self {
		case .patientDetails:
			return "PATIENT DETAILS"
		case .template(let template):
			return title(template: template)
		case .aftercare:
			return "AFTERCARE"
		}
	}

	private func title(template: FormTemplate) -> String {
		switch template.formType {
		case .consent, .treatment:
			return template.name
		case .history:
			return "HISTORY"
		case .prescription:
			return "PRESCRIPTION"
		}
	}
}

public struct MetaFormAndStatus: Equatable, Hashable {
	var form: MetaForm
	var isComplete: Bool

	init(_ form: MetaForm, _ isComplete: Bool) {
		self.form = form
		self.isComplete = isComplete
	}
}

public enum StepFormsAction {
	case didSelectNextForm
	case didSelectFormIndex(Int)
	case action2(Indexed<StepFormsAction2>)
}

public enum StepFormsAction2 {
	case didUpdateTemplate(FormTemplate)
	case didUpdatePatientDetails(PatientDetails)
	case didFinishTemplate(FormTemplate)
	case didFinishPatientDetails(PatientDetails)
}

let stepFormsReducer2 = Reducer<MetaFormAndStatus, StepFormsAction2, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didFinishPatientDetails:
		break
	case .didUpdateTemplate(let template):
		state = .init(.template(template), state.isComplete)
	case .didUpdatePatientDetails:
		break
	case .didFinishTemplate(let template):
		state = .init(.template(template), true)
	}
	return []
}

let stepFormsReducer = Reducer<CheckInContainerState, StepFormsAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didSelectFormIndex(let idx):
		state.selectedFormIndex = idx
	case .action2:
		break
	case .didSelectNextForm:
		if state.patientForms.count > state.selectedFormIndex + 1 {
			state.selectedFormIndex += 1
		}
	}

//	func handleNextBtn(state: inout CheckInContainerState) -> [StepFormsAction] {
//
//	}
//	func update(state: inout CheckInContainerState, form: MetaForm) {
//		switch form {
//		case .aftercare(let aftercare):
//			state.aftercare = aftercare
//		case .template(let template):
//			update(state: &state, template: template)
//		case .patientDetails(let patientDetails):
//			state.patientDetails = patientDetails
//		}
//	}
//
//	func update(state: inout CheckInContainerState, template: FormTemplate) {
//		switch template.formType {
//		case .consent:
//			state.consents.removeAll(where: { $0.id == template.id })
//			state.consents.append(template)
//		case .treatment:
//			state.treatments.removeAll(where: { $0.id == template.id })
//			state.treatments.append(template)
//		case .history:
//			state.history = template
//		case .prescription:
//			state.presription = template
//		}
//	}

	return []
}

struct StepForms: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	let store: Store<CheckInContainerState, StepFormsAction>
	@ObservedObject var viewStore: ViewStore<CheckInContainerState, StepFormsAction>

//	struct State {
//		var forms: [MetaForm]
//		var runningForms: [MetaForm]
//		var selectedFormIndex: Int
//		var completedForms: [Int: Bool]
//	}

	init(store: Store<CheckInContainerState, StepFormsAction>) {
		self.store = store
		self.viewStore = store.view(removeDuplicates: ==)
	}

	var body: some View {
		print("check in main body")
		return GeometryReader { geo in
			VStack(spacing: 8) {
				StepsCollectionView(steps: self.viewStore.value.patientForms,
														selectedIdx: self.viewStore.value.selectedFormIndex) {
															self.viewStore.send(.didSelectFormIndex($0))
				}
				.frame(minWidth: 240, maxWidth: 480, alignment: .center)
				.frame(height: 80)
				Divider()
					.frame(width: geo.size.width)
					.shadow(color: Color(hex: "C1C1C1"), radius: 4, y: 2)
				PabauFormWrap(store: self.store.scope(
					value: { $0.patientForms[self.viewStore.value.selectedFormIndex] },
					action: { .action2(
						Indexed(index: self.viewStore.value.selectedFormIndex,
										value: $0))}
					)
				).padding(.bottom, self.keyboardHandler.keyboardHeight > 0 ? self.keyboardHandler.keyboardHeight : 32)
					.padding([.leading, .trailing, .top], 32)
				Spacer()
				if self.keyboardHandler.keyboardHeight == 0 {
					BigButton(text: Texts.next) {
						self.viewStore.send(.didSelectNextForm)
					}
					.frame(width: 230)
					.padding(8)
				}
			}	.padding(.leading, 40)
				.padding(.trailing, 40)
		}
	}
}
