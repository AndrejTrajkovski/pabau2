import Model
import SwiftUI
import ComposableArchitecture
import CasePaths
import Util

//let fieldsReducer: Reducer<CheckInContainerState, CheckInMainAction, JourneyEnvironemnt> =
//	indexed(reducer: fieldReducer,
//					\CheckInContainerState.currentFields,
//					/CheckInMainAction.form, { $0 })

//let fieldReducer: Reducer<CSSField, CheckInFormAction, JourneyEnvironemnt> =
//(
//	cssClassReducer.pullback(
//					 value: \CSSField.cssClass,
//					 action: /CheckInFormAction.self,
//					 environment: { $0 })
//)

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

	var body: some View {
		Group {
			if self.viewStore.value.template != nil {
				PabauForm(template:
					Binding.init(
						get: { self.viewStore.value.template! },
						set: { self.viewStore.send(.didUpdateTemplate($0)) })
				)
			}
			if self.viewStore.value.patientDetails != nil {
				Text("Patient details")
			}
			if self.viewStore.value.aftercare != nil {
				Text("Aftercare")
			}
		}
	}
}

struct PabauForm: View {

	@EnvironmentObject var keyboardHandler: KeyboardFollower
	@Binding var template: FormTemplate
	init(template: Binding<FormTemplate>) {
		self._template = template
		UITableViewHeaderFooterView.appearance().tintColor = UIColor.white
		UITableView.appearance().separatorStyle = .none
	}

	public var body: some View {
		print("pabau form body")
		return List {
			ForEach(template.formStructure.formStructure.indices, id: \.self ) { index in
				FormSectionField(cssField:
					Binding(
						get: { self.template.formStructure.formStructure[index] },
						set: {
							(newValue) in self.template.formStructure.formStructure[index] = newValue
					})
				).equatable()
			}
		}.padding(.bottom, keyboardHandler.keyboardHeight)
	}
}
