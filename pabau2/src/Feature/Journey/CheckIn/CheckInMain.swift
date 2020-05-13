import SwiftUI
import Model
import ComposableArchitecture
import Util
import Overture

public enum CheckInMainAction {
	case stepForms(StepFormsAction)
	case complete
}

//struct PatientCheckInMain: View {
//	let store: Store<PatientCheckInState, CheckInMainAction>
//	var body: some View {
//		CheckInMain(store: <#T##Store<CheckInContainerState, CheckInContainerAction>#>, journey: <#T##Journey#>, journeyMode: <#T##JourneyMode#>, onClose: <#T##() -> Void#>)
//	}
//}

struct CheckInMain: View {
	let journey: Journey
	let store: Store<CheckInContainerState, CheckInContainerAction>
	@ObservedObject var viewStore: ViewStore<StepsState, CheckInMainAction>
	let journeyMode: JourneyMode
	let onClose: () -> Void
	init(store: Store<CheckInContainerState, CheckInContainerAction>,
			 journey: Journey,
			 journeyMode: JourneyMode,
			 onClose: @escaping () -> Void) {
		self.journey = journey
		self.journeyMode = journeyMode
		self.store = store
		self.viewStore = ViewStore(self.store
			.scope(state: {
				switch journeyMode {
				case .patient:
					return $0.patient
				case .doctor:
					return $0.doctor
				}
			},
			action: {
				switch journeyMode {
				case .patient:
					return .patient($0)
				case .doctor:
					return .doctor($0)
				}
			}
		))
		self.onClose = onClose
	}

	var body: some View {
		print("check in main body")
		return
			VStack (alignment: .center, spacing: 0) {
				TopView(journey: self.journey, viewStore: self.viewStore, onClose: onClose)
				StepForms(store: self.store, journeyMode: self.journeyMode)
				Spacer()
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}

struct XButton: View {
	let onTap: () -> Void
	var body: some View {
		Button.init(action: onTap, label: {
			Image(systemName: "xmark")
				.font(Font.light30)
				.foregroundColor(.gray142)
				.frame(width: 30, height: 30)
		})
	}
}

public struct PatientDetails: Equatable, Hashable { }

public struct Recall: Equatable, Hashable { }

public struct Aftercare: Equatable, Hashable { }

public struct PatientComplete: Equatable, Hashable { }

public enum MetaForm: Equatable, Hashable, CustomDebugStringConvertible {
	
	public var debugDescription: String {
		switch self {
		case .patientDetails:
			return "PATIENT DETAILS"
		case .template(let template):
			return template.debugDescription
		case .aftercare:
			return "AFTERCARE"
		case .patientComplete:
			return "COMPLETE"
		}
	}
	
	init(_ patD: PatientDetails) {
		self = .patientDetails(patD)
	}
	
	init(_ aftercare: Aftercare) {
		self = .aftercare(aftercare)
	}
	
	init(_ template: FormTemplate) {
		self = .template(template)
	}
	
	init(_ patientComplete: PatientComplete) {
		self = .patientComplete(patientComplete)
	}
	
	case patientDetails(PatientDetails)
	case aftercare(Aftercare)
	case template(FormTemplate)
	case patientComplete(PatientComplete)

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

public struct MetaFormAndStatus: Equatable, Hashable, CustomDebugStringConvertible {
	
	public var debugDescription: String {
		return form.debugDescription
	}
	
	static let defaultEmpty = MetaFormAndStatus.init(MetaForm.template(FormTemplate.defaultEmpty), false)

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
	case childForm(Indexed<ChildFormAction>)
}

public enum ChildFormAction {
	case didUpdateTemplate(FormTemplate)
	case didUpdatePatientDetails(PatientDetails)
	case didFinishTemplate(MetaFormAndStatus)
	case didFinishPatientDetails(PatientDetails)
}

let stepFormsReducer2 = Reducer<MetaFormAndStatus, ChildFormAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .didFinishPatientDetails:
		break
	case .didUpdateTemplate(let template):
		state = .init(.template(template), state.isComplete)
	case .didUpdatePatientDetails:
		break
	case .didFinishTemplate(let template):
		state.isComplete = true
	}
	return .none
}

let stepFormsReducer = Reducer<StepsState, StepFormsAction, JourneyEnvironemnt> { state, action, _ in
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

struct StepForms: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	let store: Store<CheckInContainerState, CheckInContainerAction>
	let journeyMode: JourneyMode
	@ObservedObject var viewStore: ViewStore<StepsState, StepFormsAction>

	init(store: Store<CheckInContainerState, CheckInContainerAction>,
			 journeyMode: JourneyMode) {
		self.store = store
		self.journeyMode = journeyMode
		self.viewStore = ViewStore(self.store
			.scope(state: {
				switch journeyMode {
				case .patient:
					return $0.patient
				case .doctor:
					return $0.doctor
				}
			},
			 action: {
				switch journeyMode {
				case .patient:
					return .patient(.stepForms($0))
				case .doctor:
					return .doctor(.stepForms($0))
				}
			}))
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
				PabauFormWrap(store: self.store,
											selectedFormIndex: self.viewStore.state.selectedIndex,
											journeyMode: self.journeyMode)
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
