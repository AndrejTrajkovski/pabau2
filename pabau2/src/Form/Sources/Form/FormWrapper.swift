import Model
import SwiftUI
import ComposableArchitecture
import Util

public typealias Indexed<T> = (Int, T)

public let metaFormAndStatusReducer: Reducer<MetaFormAndStatus, UpdateFormAction, FormEnvironment> =
	metaFormReducer.pullback(
		state: \MetaFormAndStatus.form,
		action: /UpdateFormAction.self,
		environment: { $0 }
	)

let metaFormReducer: Reducer<MetaForm, UpdateFormAction, FormEnvironment> =
	Reducer<MetaForm, UpdateFormAction, FormEnvironment>.combine(
		Reducer.init { state, action, _ in
			switch action {
			//FIXME: GO WITH REDUX FOR TEMPLATES
			case .template(let template):
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
	case template(FormTemplate)
	case patientDetails(PatientDetailsAction)
	case aftercare(AftercareAction)
	case photos(PhotosFormAction)
}

//FIXME: REFACTOR TO FACTORY METHOD
public struct FormWrapper: View {
	let store: Store<MetaForm, UpdateFormAction>
	@ObservedObject var viewStore: ViewStore<MetaForm, UpdateFormAction>
	public init(store: Store<MetaForm, UpdateFormAction>) {
		self.store = store
		self.viewStore = ViewStore(store)
	}
	
	//FIXME: With SwiftUI 2.0 use switch inside the body
	//FIXME: With SwiftUI 2.0 Test with Group instead of AnyView
	public var body: some View {
		switch self.viewStore.state {
		case .patientDetails:
			IfLetStore(store.scope(
						state: { extract(case: MetaForm.patientDetails, from: $0)},
						action: { .patientDetails($0) }),
					   then: PatientDetailsForm.init(store:))
		case .aftercare:
			IfLetStore(store.scope(
						state: { extract(case: MetaForm.aftercare, from: $0)},
						action: { .aftercare($0) }),
					   then: AftercareForm.init(store:))
		case .template:
			IfLetStore(store.scope(
						state: { extract(case: MetaForm.template, from: $0)},
						action: { .template($0) }),
					   then: { store in
						return EmptyView()
					   })
		case .patientComplete:
			IfLetStore(store.scope(
						state: { extract(case: MetaForm.patientComplete, from: $0)},
						action: { .patientComplete($0) }),
					   then: PatientCompleteForm.init(store:))
		case .checkPatient:
			IfLetStore(store.scope(
						state: { extract(case: MetaForm.checkPatient, from: $0)})
						.actionless,
					   then: CheckPatientFormStore.init(store:))
		case .photos:
			IfLetStore(store.scope(
						state: { extract(case: MetaForm.photos, from: $0)},
						action: { .photos($0) }),
					   then: PhotosForm.init(store:))
		}
	}
}

//if self.viewStore.state.template != nil {
//	ListDynamicForm(template:
//		Binding.init(
//			get: { self.viewStore.state.template ?? FormTemplate.defaultEmpty },
//			set: { self.viewStore.send(.template($0)) })
//	)
//} else if self.viewStore.state.patientDetails != nil {
//	IfLetStore(
//		self.store.scope(
//			state: { extract(case: MetaForm.patientDetails, from: $0) },
//			action: { .patientDetails($0) }),
//		then: PatientDetailsForm.init(store:)
//	)
//} else if self.viewStore.state.patientCompleteForm != nil {
//	IfLetStore(
//		self.store.scope(
//			state: { extract(case: MetaForm.patientComplete, from: $0) },
//			action: { .patientComplete($0) }),
//		then: PatientCompleteForm.init(store:)
//	)
//} else if self.viewStore.state.checkPatient?.patDetails != nil {
//	CheckPatientForm(didTouchDone: { },
//									 patDetails: self.viewStore.state.checkPatient!.patDetails!,
//									 patientForms: self.viewStore.state.checkPatient!.patForms)
//} else if self.viewStore.state.photos != nil {
//	IfLetStore(
//		self.store.scope(
//			state: { extract(case: MetaForm.photos, from: $0) },
//			action: { .photos($0) }),
//		then: PhotosForm.init(store:)
//	)
//} else if self.viewStore.state.aftercare != nil {
//	IfLetStore(
//		self.store.scope(
//			state: { extract(case: MetaForm.aftercare, from: $0) },
//			action: { .aftercare($0) }),
//		then: AftercareForm.init(store:)
//	)
//}
