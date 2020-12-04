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
		formTemplateReducer.pullbackCp(
			state: /MetaForm.template,
			action: /UpdateFormAction.template,
			environment: { $0 }),
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
	case template(FormTemplateAction)
	case patientDetails(PatientDetailsAction)
	case aftercare(AftercareAction)
	case photos(PhotosFormAction)
}

//FIXME: REFACTOR TO FACTORY METHOD
public struct FormWrapper: View {
	let store: Store<MetaForm, UpdateFormAction>
	public init(store: Store<MetaForm, UpdateFormAction>) {
		self.store = store
	}

	public var body: some View {
		IfLetStore(store.scope(
					state: { extract(case: MetaForm.patientDetails, from: $0)},
					action: { .patientDetails($0) }),
				   then: PatientDetailsForm.init(store:))
		IfLetStore(store.scope(
					state: { extract(case: MetaForm.aftercare, from: $0)},
					action: { .aftercare($0) }),
				   then: AftercareForm.init(store:))
		IfLetStore(store.scope(
					state: { extract(case: MetaForm.template, from: $0)},
					action: { .template($0) }),
				   then: ListDynamicForm.init(store:)
		)
		IfLetStore(store.scope(
					state: { extract(case: MetaForm.patientComplete, from: $0)},
					action: { .patientComplete($0) }),
				   then: PatientCompleteForm.init(store:)
		)
		IfLetStore(store.scope(
					state: { extract(case: MetaForm.checkPatient, from: $0)})
					.actionless,
				   then: CheckPatientForm.init(store:)
		)
		IfLetStore(store.scope(
					state: { extract(case: MetaForm.photos, from: $0)},
					action: { .photos($0) }),
				   then: PhotosForm.init(store:)
		)
	}
}
