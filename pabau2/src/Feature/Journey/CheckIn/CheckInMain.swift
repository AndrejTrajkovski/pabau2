import SwiftUI
import Model
import ComposableArchitecture
import Util

public enum CheckInMainAction {
	case closeBtnTap
	case patient(StepFormsAction)
}

let checkInMainReducer = Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> { state, action, _ in
	switch action {
	case .closeBtnTap:
		//handled elsewhere
		break
	case .patient(_):
		break
	}
	return []
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
						value: { $0.patient },
						action: { .patient($0) }))
				Spacer()
			}
			.navigationBarTitle("")
			.navigationBarHidden(true)
	}
}

public struct PatientDetails: Equatable {
}

public struct Aftercare: Equatable {
}

public enum MetaForm: Equatable {
	case patientDetails(PatientDetails)
	case aftercare(Aftercare)
	case template(FormTemplate)
	
	var title: String {
		switch self {
		case .patientDetails(_):
			return "PATIENT DETAILS"
		case .template(let template):
			return title(template: template)
		case .aftercare(_):
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

struct StepFormsState: Equatable {
	let journeyMode: JourneyMode
	let steps: [Step]
//	var templates: [FormTemplate]
//	var patientDetails: PatientDetails
//	var consents: [FormTemplate]
//	var medicalHistory: FormTemplate?
//	var treatmentNotes: [FormTemplate]
//	var aftercare: Aftercare?
	
	var forms: [MetaForm]
	var runningForms: [MetaForm]
	var selectedFormIndex: Int
	var completedForms: [Int: Bool]
	
	var selectedForm: MetaForm {
		get { runningForms[selectedFormIndex] }
		set { runningForms[selectedFormIndex] = newValue }
	}
	
	func patientMode(steps: [Step],
									 patientDetails: PatientDetails?,
									 medicalHistory: FormTemplate?,
									 consents: [FormTemplate]
									 ) -> [MetaForm] {
		let steps = steps.filter { stepToModeMap[$0.stepType] == .patient }
		var result = [MetaForm]()
		steps.forEach { step in
			switch step.stepType {
			case .consents:
				result += consents.map(MetaForm.template)
			case .patientdetails:
				guard let patientDetails = patientDetails else {}
				result.append(.patientDetails(patientDetails))
			case .medicalhistory:
				guard let medicalHistory = medicalHistory else {}
				result.append(.template(medicalHistory))
			case .checkpatient,
				.treatmentnotes,
				.prescriptions,
				.photos,
				.recalls,
				.aftercares:
				fatalError("doctor steps, should be filtered earlier")
			}
		}
	}
}

public enum StepFormsAction {
	case didUpdateSelectedForm(MetaForm)
//	case didUpdatePatientDetails(PatientDetails)
//	case didUpdateFields([CSSField])
	case didSelectStepIdx(Int)
	case didFinishTemplateIdx(Int)
}

let stepFormsReducer = Reducer<StepFormsState, StepFormsAction, JourneyEnvironemnt> { state, action, env in
	switch action {
	case .didUpdateSelectedForm(let form):
		state.selectedForm = form
	case .didSelectStepIdx(let idx):
		state.selectedFormIndex = idx
	case .didFinishTemplateIdx(let idx):
		state.forms[idx] = state.runningForms[idx]
		state.completedForms[idx] = true
	}
	return []
}

struct StepForms: View {
	
	let store: Store<StepFormsState, StepFormsAction>
	@ObservedObject var viewStore: ViewStore<StepFormsState, StepFormsAction>
	
//	struct State {
//		var forms: [MetaForm]
//		var runningForms: [MetaForm]
//		var selectedFormIndex: Int
//		var completedForms: [Int: Bool]
//	}
	
	init(store: Store<StepFormsState, StepFormsAction>) {
		self.store = store
		self.viewStore = store.view(removeDuplicates: ==)
	}
	
	var body: some View {
		VStack {
			StepsCollectionView(steps: self.viewStore.value.forms,
													selectedIdx: self.viewStore.value.selectedFormIndex) {
														self.viewStore.send(.didSelectStepIdx($0))
		}
		.frame(minWidth: 240, maxWidth: 480, alignment: .center)
		.frame(height: 80)
			PabauFormWrap(store: self.store.scope(
				value: { $0.runningForms[$0.selectedFormIndex] },
				action: { $0 }))
		}
			.padding(.leading, 40)
			.padding(.trailing, 40)
	}
}
