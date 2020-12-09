import Model
import SwiftUI
import ComposableArchitecture
import Util

public typealias Indexed<T> = (Int, T)

//public let metaFormAndStatusReducer: Reducer<MetaFormAndStatus, UpdateFormAction, FormEnvironment> =
//	metaFormReducer.pullback(
//		state: \MetaFormAndStatus.form,
//		action: /UpdateFormAction.self,
//		environment: { $0 }
//	)

//let metaFormReducer: Reducer<MetaForm, UpdateFormAction, FormEnvironment> =
//	Reducer<MetaForm, UpdateFormAction, FormEnvironment>.combine(
//		formTemplateReducer.pullbackCp(
//			state: /MetaForm.template,
//			action: /UpdateFormAction.template,
//			environment: { $0 }),
//		patientCompleteReducer.pullbackCp(
//			state: /MetaForm.patientComplete,
//			action: /UpdateFormAction.patientComplete,
//			environment: { $0 }),
//		patientDetailsReducer.pullbackCp(
//			state: /MetaForm.patientDetails,
//			action: /UpdateFormAction.patientDetails,
//			environment: { $0 }),
//		aftercareReducer.pullbackCp(
//			state: /MetaForm.aftercare,
//			action: /UpdateFormAction.aftercare,
//			environment: { $0 }),
//		photosFormReducer.pullbackCp(
//			state: /MetaForm.photos,
//			action: /UpdateFormAction.photos,
//			environment: { $0 })
//	)
