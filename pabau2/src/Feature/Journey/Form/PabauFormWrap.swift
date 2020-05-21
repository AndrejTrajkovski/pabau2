import Model
import SwiftUI
import ComposableArchitecture
import Util

public typealias Indexed<T> = (Int, T)

struct PabauFormWrap: View {
	let store: Store<MetaFormAndStatus, ChildFormAction>
	@ObservedObject var viewStore: ViewStore<State, ChildFormAction>

	init(store: Store<MetaFormAndStatus, ChildFormAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(
			state: State.init(state:),
			action: { $0 }))
	}

	struct State: Equatable {
		var patientDetails: PatientDetails?
		var template: FormTemplate?
		var aftercare: Aftercare?
		var patientCompleteForm: PatientComplete?
		static var defaultEmpty: State {
			State.init(state: MetaFormAndStatus.defaultEmpty)
		}
		init (state: MetaFormAndStatus) {
			self.patientDetails = extract(case: MetaForm.patientDetails, from: state.form)
			self.template = extract(case: MetaForm.template, from: state.form)
			self.aftercare = extract(case: MetaForm.aftercare, from: state.form)
			self.patientCompleteForm = extract(case: MetaForm.patientComplete, from: state.form)
		}
	}

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
			return AnyView(
				PatientDetailsForm(patientDetails: self.viewStore.state.patientDetails!)
					.padding()
			)
		} else if self.viewStore.state.patientCompleteForm != nil {
			return AnyView(
				IfLetStore(
					self.store.scope(
						state: { extract(case: MetaForm.patientComplete, from: $0.form) },
						action: { .patientComplete($0) }),
					then: PatientCompleteForm.init(store:)
				)
			)
		} else {
			return AnyView(Text("Aftercare"))
		}
	}
}
//
//self.store = store
//self.journeyMode = journeyMode
//self.viewStore = ViewStore(store.scope(
//	state: {
//		let forms = getForms(journeyMode, $0)
//		if forms.count > selectedFormIndex {
//			return State.init(state: forms[selectedFormIndex])
//		} else {
//			return State.defaultEmpty
//		}
//},
//	action: {
//		switch journeyMode {
//		case .patient:
//			return .patient(.stepForms(.childForm(Indexed(selectedFormIndex, $0))))
//		case .doctor:
//			return .doctor(.stepForms(.childForm(Indexed(selectedFormIndex, $0))))
//		}
//}))
