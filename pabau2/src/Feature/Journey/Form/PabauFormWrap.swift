import Model
import SwiftUI
import ComposableArchitecture

import Util

struct PabauFormWrap: View {
	let store: Store<CheckInContainerState, CheckInMainAction>
	@ObservedObject var viewStore: ViewStore<State, StepFormsAction2>
	let journeyMode: JourneyMode

	struct State: Equatable {
		var patientDetails: PatientDetails?
		var template: FormTemplate?
		var aftercare: Aftercare?
		var isCompleteForm: Bool
		static var defaultEmpty: State {
			State.init(state: MetaFormAndStatus.defaultEmpty)
		}
		init (state: MetaFormAndStatus) {
			self.patientDetails = extract(case: MetaForm.patientDetails, from: state.form)
			self.template = extract(case: MetaForm.template, from: state.form)
			self.aftercare = extract(case: MetaForm.aftercare, from: state.form)
			self.isCompleteForm = extract(case: MetaForm.patientComplete, from: state.form) != nil
		}
	}

	init(store: Store<CheckInContainerState, CheckInMainAction>,
			 selectedFormIndex: Int,
			 journeyMode: JourneyMode) {
		self.store = store
		self.journeyMode = journeyMode
		self.viewStore = self.store.scope(
			state: {
				if ($0.patient.forms.count > selectedFormIndex) {
					let formState = $0.patient.forms[selectedFormIndex]
						return State.init(state: formState)
				} else {
					return State.defaultEmpty
				}
		},
			action: {
				switch journeyMode {
				case .patient:
					return .patient(.action2(Indexed(index: selectedFormIndex, value: $0)))
				case .doctor:
					return .doctor(.action2(Indexed(index: selectedFormIndex, value: $0)))
				}
		}).view
//		self.viewStore = store.scope(
//			value: State.init(state:),
//			action: { $0 }).view
	}

//	var body: some View {
//		print("pabau wrapper body ")
//		return Group {
//			if self.viewStore.state.template != nil {
//				DynamicForm(template:
//					Binding.init(
//						get: { self.viewStore.state.template ?? FormTemplate.defaultEmpty },
//						set: { self.viewStore.send(.didUpdateTemplate($0)) })
//				)
//			}
//			if self.viewStore.state.patientDetails != nil {
//				PatientDetailsForm()
//			}
//			if self.viewStore.state.aftercare != nil {
//				Text("Aftercare")
//			}
//		}.padding()
//	}

	var body: some View {
		if self.viewStore.state.template != nil {
			return AnyView(
				DynamicForm(template:
					Binding.init(
						get: { self.viewStore.state.template ?? FormTemplate.defaultEmpty },
						set: { self.viewStore.send(.didUpdateTemplate($0)) })
				)
			)
		} else if self.viewStore.state.patientDetails != nil {
			return AnyView(PatientDetailsForm().padding())
		} else if self.viewStore.state.isCompleteForm {
			return AnyView(CompleteStepForm(store: store))
		} else {
			return AnyView(Text("Aftercare"))
		}
	}
}
