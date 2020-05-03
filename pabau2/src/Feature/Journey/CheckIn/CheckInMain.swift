import SwiftUI
import Model
import ComposableArchitecture
import Util

public enum CheckInMainAction {
	case closeBtnTap
	case patient(StepFormsAction)
	case doctor(StepFormsAction)
}

struct CheckInMain: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<State, CheckInMainAction>
	let journeyMode: JourneyMode
	init(store: Store<CheckInContainerState, CheckInMainAction>,
			 journeyMode: JourneyMode) {
		self.journeyMode = journeyMode
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
						action: { $0 }
					),
					journeyMode: self.journeyMode)
				Spacer()
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}

public struct PatientDetails: Equatable, Hashable { }

public struct Aftercare: Equatable, Hashable { }

public enum MetaForm: Equatable, Hashable {
	case patientDetails(PatientDetails)
	case aftercare(Aftercare)
	case template(FormTemplate)
	case patientComplete
	
	var title: String {
		switch self {
		case .patientDetails:
			return "PATIENT DETAILS"
		case .template(let template):
			return title(template: template)
		case .aftercare:
			return "AFTERCARE"
		case .patientComplete:
			return "COMPLETE"
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
	return []
}

struct StepForms: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	let store: Store<CheckInContainerState, CheckInMainAction>
	let journeyMode: JourneyMode
	@ObservedObject var viewStore: ViewStore<CheckInContainerState, StepFormsAction>

	init(store: Store<CheckInContainerState, CheckInMainAction>,
			 journeyMode: JourneyMode) {
		self.store = store
		self.journeyMode = journeyMode
		self.viewStore = self.store
			.scope(value: { $0 },
						 action: {
							switch journeyMode {
							case .patient:
								return .patient($0)
							case .doctor:
								return .doctor($0)
							}
			}).view
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
				PabauFormWrap(store: self.store,
											selectedFormIndex: self.viewStore.value.selectedFormIndex,
											journeyMode: self.journeyMode)
					.padding(.bottom, self.keyboardHandler.keyboardHeight > 0 ? self.keyboardHandler.keyboardHeight : 32)
					.padding([.leading, .trailing, .top], 32)
				Spacer()
				if self.keyboardHandler.keyboardHeight == 0 &&
					!self.viewStore.value.isOnCompleteStep {
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
