import ComposableArchitecture
import Model
import Overture
import Form

//func doctorStepForms(stepType: StepType,
//					 patientDetails: PatientDetails,
//					 medHistory: FormTemplate,
//					 consents: IdentifiedArrayOf<FormTemplate>,
//					 treatmentNotes: IdentifiedArrayOf<FormTemplate>,
//					 prescriptions: IdentifiedArrayOf<FormTemplate>,
//					 photos: PhotosState) -> [MetaFormAndStatus] {
//	switch stepType {
//	case .aftercares:
//		return [MetaFormAndStatus(MetaForm.aftercare(JourneyMocks.aftercare), index: 0)]
//	case .checkpatient:
//		let patientForms = [medHistory] + consents
//		let checkPatient = CheckPatient(patDetails: patientDetails, patForms: patientForms)
//		return [MetaFormAndStatus(MetaForm.checkPatient(checkPatient), index: 0)]
//	case .treatmentnotes:
//		return wrap(treatmentNotes)
//	case .photos:
//		return [MetaFormAndStatus(MetaForm.photos(photos), index: 0)]
//	case .prescriptions:
//		return wrap(prescriptions)
//	case .patientdetails, .consents, .patientComplete, .medicalhistory:
//		fatalError("patient steps")
//	}
//}
//
func wrap(_ templates: IdentifiedArrayOf<FormTemplate>) -> IdentifiedArrayOf<MetaFormAndStatus> {
	let arr = zip(templates.indices, templates).map { idx, template in
		return MetaFormAndStatus(MetaForm.template(template), false, index: idx)
	}
	return IdentifiedArrayOf(arr)
}
//
//func patientStepForms(stepType: StepType,
//					  consents: IdentifiedArrayOf<FormTemplate>) -> [MetaFormAndStatus] {
//	switch stepType {
//	case .patientdetails:
//		return [MetaFormAndStatus(MetaForm.patientDetails(PatientDetails.empty), index: 0)]
//	case .medicalhistory:
//		return [MetaFormAndStatus(MetaForm.init(FormTemplate.getMedHistory()), index: 0)]
//	case .consents:
//		return zip(consents.indices, consents).map { idx, consent in
//			return MetaFormAndStatus(MetaForm.template(consent), index: idx)
//		}
//	case .patientComplete:
//		return [MetaFormAndStatus(MetaForm.patientComplete(PatientComplete()), index: 0)]
//	case .aftercares, .checkpatient, .photos, .prescriptions, .treatmentnotes:
//		fatalError("doctor steps")
//	}
//}
//
//func patientStepForms(stepType: StepType,
//					  consents: IdentifiedArrayOf<FormTemplate>) -> StepForms {
//	let formsRaw: [MetaFormAndStatus] = patientStepForms(stepType: stepType, consents: consents)
//	return StepForms(stepType: stepType,
//					 forms: IdentifiedArray(formsRaw),
//					 selFormIndex: 0)
//}
//
//func makePatientForms(stepTypes: [StepType],
//					  consents: IdentifiedArrayOf<FormTemplate>) -> [StepForms] {
//	stepTypes.map { patientStepForms(stepType: $0,
//									 consents: consents)
//	}
//}
//
//func makeDoctorForms(stepTypes:[StepType],
//					 patientDetails: PatientDetails,
//					 medHistory: FormTemplate,
//					 consents: IdentifiedArrayOf<FormTemplate>,
//					 treatmentNotes: IdentifiedArrayOf<FormTemplate>,
//					 prescriptions: IdentifiedArrayOf<FormTemplate>,
//					 photos: PhotosState) -> [StepForms] {
//	stepTypes.map { doctorStepForms(stepType: $0,
//									patientDetails: patientDetails,
//									medHistory: medHistory,
//									consents: consents,
//									treatmentNotes: treatmentNotes,
//									prescriptions: prescriptions,
//									photos: photos)
//	}
//}
//
//func doctorStepForms(stepType: StepType,
//					 patientDetails: PatientDetails,
//					 medHistory: FormTemplate,
//					 consents: IdentifiedArrayOf<FormTemplate>,
//					 treatmentNotes: IdentifiedArrayOf<FormTemplate>,
//					 prescriptions: IdentifiedArrayOf<FormTemplate>,
//					 photos: PhotosState) -> StepForms {
//	let formsRaw: [MetaFormAndStatus] = doctorStepForms(stepType: stepType,
//														patientDetails: patientDetails,
//														medHistory: medHistory,
//														consents: consents,
//														treatmentNotes: treatmentNotes,
//														prescriptions: prescriptions,
//														photos: photos
//	)
//	return StepForms(stepType: stepType,
//					 forms: IdentifiedArray(formsRaw),
//					 selFormIndex: 0)
//}
//
func updateWithKeepingOld(forms: inout [FormTemplate],
						  finalSelectedTemplatesIds: [Int],
						  allTemplates: IdentifiedArrayOf<FormTemplate>) {
	let oldWithData = forms.filter { old in
		finalSelectedTemplatesIds.contains(old.id)
	}
	let allNew = selected(allTemplates, finalSelectedTemplatesIds)
	let oldWithDataDict = Dictionary.init(grouping: oldWithData,
										  by: \.id)
	let allNewDict = Dictionary.init(grouping: allNew,
									 by: \.id)
	let result = oldWithDataDict.merging(allNewDict,
										 uniquingKeysWith: { (old, _) in
											return old
										 }).flatMap(\.value)
	forms = result
}
