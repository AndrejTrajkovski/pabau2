import Model
import SwiftUI
import ComposableArchitecture
import CasePaths
import Util

struct PabauFormWrap: View {
	let store: Store<MetaFormAndStatus, StepFormsAction2>
	@ObservedObject var viewStore: ViewStore<State, StepFormsAction2>

	struct State: Equatable {
		var patientDetails: PatientDetails?
		var template: FormTemplate?
		var aftercare: Aftercare?
		init (state: MetaFormAndStatus) {
			self.patientDetails = extract(case: MetaForm.patientDetails, from: state.form)
			self.template = extract(case: MetaForm.template, from: state.form)
			self.aftercare = extract(case: MetaForm.aftercare, from: state.form)
		}
	}

	init(store: Store<MetaFormAndStatus, StepFormsAction2>) {
		self.store = store
		self.viewStore = store.scope(
			value: State.init(state:),
			action: { $0 }).view
	}

//	var body: some View {
//		print("pabau wrapper body ")
//		return Group {
//			if self.viewStore.value.template != nil {
//				DynamicForm(template:
//					Binding.init(
//						get: { self.viewStore.value.template ?? FormTemplate.defaultEmpty },
//						set: { self.viewStore.send(.didUpdateTemplate($0)) })
//				)
//			}
//			if self.viewStore.value.patientDetails != nil {
//				PatientDetailsForm()
//			}
//			if self.viewStore.value.aftercare != nil {
//				Text("Aftercare")
//			}
//		}.padding()
//	}

	var body: some View {
		if self.viewStore.value.template != nil {
			return AnyView(
				DynamicForm(template:
					Binding.init(
						get: { self.viewStore.value.template ?? FormTemplate.defaultEmpty },
						set: { self.viewStore.send(.didUpdateTemplate($0)) })
				)
			)
		} else if self.viewStore.value.patientDetails != nil {
			return AnyView(PatientDetailsForm())
		} else {
			return AnyView(Text("Aftercare"))
		}
	}
}
