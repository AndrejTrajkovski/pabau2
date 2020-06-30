import Model
import SwiftUI
import ComposableArchitecture
import Util

public typealias Indexed<T> = (Int, T)

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
			//FIXME: GO WITH REDUX FOR TEMPLATES
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
			environment: { $0 }),
		aftercareReducer.pullbackCp(
			state: /MetaForm.aftercare,
			action: /UpdateFormAction.aftercare,
			environment: { $0 }),
		photosFormReducer.pullbackCp(
			state: /MetaForm.photos,
			action: /UpdateFormAction.photos,
			environment: { $0 })
)

public enum UpdateFormAction {
	case patientComplete(PatientCompleteAction)
	case didUpdateTemplate(FormTemplate)
	case patientDetails(PatientDetailsAction)
	case aftercare(AftercareAction)
	case photos(PhotosFormAction)
}

//FIXME: REFACTOR TO FACTORY METHOD
struct FormWrapper: View {
	let store: Store<MetaForm, UpdateFormAction>
	@ObservedObject var viewStore: ViewStore<State, UpdateFormAction>

	init(store: Store<MetaForm, UpdateFormAction>) {
		self.store = store
		self.viewStore = ViewStore(store.scope(
			state: State.init(state:),
			action: { $0 })
		, removeDuplicates: { lhs, rhs in
				if let lhs = lhs.patientDetails, let rhs = rhs.patientDetails {
					return lhs == rhs
				} else if let lhs = lhs.template, let rhs = rhs.template {
					return lhs == rhs
				} else if let lhs = lhs.aftercare, let rhs = rhs.aftercare {
						return lhs == rhs
				} else if let lhs = lhs.patientCompleteForm, let rhs = rhs.patientCompleteForm {
					return lhs == rhs
				} else if let lhs = lhs.checkPatient, let rhs = rhs.checkPatient {
					return lhs == rhs
				} else if let lhs = lhs.photos, let rhs = rhs.photos {
					return lhs == rhs
				} else {
					return false
				}
			}
		)
	}

	struct State: Equatable {
		var patientDetails: PatientDetails?
		var template: FormTemplate?
		var aftercare: Aftercare?
		var patientCompleteForm: PatientComplete?
		var checkPatient: CheckPatient?
		var photos: PhotosState?

		init (state: MetaForm) {
			self.patientDetails = extract(case: MetaForm.patientDetails, from: state)
			self.template = extract(case: MetaForm.template, from: state)
			self.aftercare = extract(case: MetaForm.aftercare, from: state)
			self.patientCompleteForm = extract(case: MetaForm.patientComplete, from: state)
			self.checkPatient = extract(case: MetaForm.checkPatient, from: state)
			self.photos = extract(case: MetaForm.photos, from: state)
		}
	}

	//FIXME: With SwiftUI 2.0 use switch inside the body
	//FIXME: With SwiftUI 2.0 Test with Group instead of AnyView
	var body: some View {
		print("form wrap body")
		if self.viewStore.state.template != nil {
			return AnyView(
				ListDynamicForm(template:
					Binding.init(
						get: { self.viewStore.state.template ?? FormTemplate.defaultEmpty },
						set: { self.viewStore.send(.didUpdateTemplate($0)) })
				)
			)
		} else if self.viewStore.state.patientDetails != nil {
			return AnyView(
				IfLetStore(
					self.store.scope(
						state: { extract(case: MetaForm.patientDetails, from: $0) },
						action: { .patientDetails($0) }),
					then: PatientDetailsForm.init(store:)
				)
			)
		} else if self.viewStore.state.patientCompleteForm != nil {
			return AnyView(
				IfLetStore(
					self.store.scope(
						state: { extract(case: MetaForm.patientComplete, from: $0) },
						action: { .patientComplete($0) }),
					then: PatientCompleteForm.init(store:)
				)
			)
		} else if self.viewStore.state.checkPatient != nil {
			return AnyView(
				CheckPatientForm(didTouchDone: { },
												 patDetails: self.viewStore.state.checkPatient!.patDetails,
												 patientForms: self.viewStore.state.checkPatient!.patForms)
			)
		} else if self.viewStore.state.photos != nil {
			return AnyView(
				IfLetStore(
					self.store.scope(
						state: { extract(case: MetaForm.photos, from: $0) },
						action: { .photos($0) }),
					then: PhotosForm.init(store:)
				)
			)
		} else if self.viewStore.state.aftercare != nil {
			return AnyView(
				IfLetStore(
					self.store.scope(
						state: { extract(case: MetaForm.aftercare, from: $0) },
						action: { .aftercare($0) }),
					then: AftercareForm.init(store:)
				)
			)
		} else {
			return AnyView(EmptyView())
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
