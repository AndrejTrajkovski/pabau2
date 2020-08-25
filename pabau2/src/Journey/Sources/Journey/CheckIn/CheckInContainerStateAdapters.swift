import ComposableArchitecture
import Model
import Overture
import Form

//func transformBack(_ journeyMode: JourneyMode,
//									 _ forms: [MetaFormAndStatus],
//									 _ checkInContainerState: inout CheckInContainerState) {
//	forms.filter(
//		with(journeyMode, filterMetaFormsByJourneyMode)
//	).forEach {
//		unwrap(&checkInContainerState, $0)
//	}
//}

//func transformInFormsArray(_ journeyMode: JourneyMode,
//													 _ state: CheckInContainerState) -> [MetaFormAndStatus] {
//	state.stepTypes
//		.filter(with(journeyMode, filterStepType))
//		.reduce(into: [MetaFormAndStatus]()) {
//			$0.append(contentsOf:
//				with($1, (with(state, curry(wrapForm(_:_:))))))
//	}
//	.sorted(by: their(pipe(get(\.form), stepType(form:), get(\.order))))
//}

//func wrapForm(_ state: CheckInContainerState,
//							_ stepType: StepType) -> [MetaFormAndStatus] {
//	switch stepType {
//	case .patientdetails:
//		let form = MetaForm.patientDetails(state.patientDetails)
//		return [MetaFormAndStatus(form, state.patientDetailsCompleted)]
//	case .medicalhistory:
//		let form = MetaForm.template(state.medHistory)
//		return [MetaFormAndStatus(form, state.medHistoryCompleted)]
//	case .consents:
//		return state.consents.toMetaFormArray()
//	case .checkpatient:
//		let form = MetaForm.checkPatient(state.checkPatient)
//		return [MetaFormAndStatus(form, state.checkPatientCompleted)]
//	case .treatmentnotes:
//		return state.treatments.toMetaFormArray()
//	case .prescriptions:
//		return state.runningPrescriptions.map {
//			let form = MetaForm.template($0.value)
//			guard let status = state.prescriptionsCompleted[$0.value.id] else { fatalError() }
//			return MetaFormAndStatus(form, status)
//		}
//	case .photos:
//		let form = MetaForm.photos(state.photosState)
//		return [MetaFormAndStatus(form, state.photosCompleted)]
//	case .aftercares:
//		let form = MetaForm.aftercare(state.aftercare)
//		return [MetaFormAndStatus(form, state.aftercareCompleted)]
//	case .patientComplete:
//		let form = MetaForm.patientComplete(state.patientComplete)
//		return [MetaFormAndStatus(form, false)]
//	}
//}

//func wrap(_ forms: inout FormsCollection,
//					_ metaForm: MetaForm,
//					_ isComplete: Bool) {
//	let consent = extract(case: MetaForm.template, from: metaForm)!
//	forms.byId[consent.id] = consent
//	forms.completed[consent.id] = isComplete
//	forms.allIds.append(consent.id)
//}

//func unwrap(_ state: inout CheckInContainerState,
//						_ metaFormAndStatus: MetaFormAndStatus) {
//	let metaForm = metaFormAndStatus.form
//	let isComplete = metaFormAndStatus.isComplete
//	switch stepType(form: metaForm) {
//	case .patientdetails:
//		state.patientDetails = extract(case: MetaForm.patientDetails, from: metaForm)!
//		state.patientDetailsCompleted = isComplete
//	case .medicalhistory:
//		state.medHistory = extract(case: MetaForm.template, from: metaForm)!
//		state.medHistoryCompleted = isComplete
//	case .consents:
//		wrap(&state.consents, metaForm, isComplete)
//	case .checkpatient:
//		state.checkPatientCompleted = isComplete
//	case .treatmentnotes:
//		wrap(&state.treatments, metaForm, isComplete)
//	case .prescriptions:
//		let prescription = extract(case: MetaForm.template, from: metaForm)!
//		state.runningPrescriptions[prescription.id] = prescription
//		state.prescriptionsCompleted[prescription.id] = isComplete
//	case .photos:
//		state.photosState = extract(case: MetaForm.photos, from: metaForm)!
//		state.photosCompleted = isComplete
//	case .aftercares:
//		state.aftercare = extract(case: MetaForm.aftercare, from: metaForm)!
//		state.aftercareCompleted = isComplete
//	case .patientComplete:
//		state.patientComplete = extract(case: MetaForm.patientComplete, from: metaForm)!
//	}
//}

func updateWithKeepingOld(forms: inout IdentifiedArrayOf<MetaFormAndStatus>,
													finalSelectedTemplatesIds: [Int],
													allTemplates: IdentifiedArrayOf<FormTemplate>) {
	let oldWithData = forms.filter { old in
		finalSelectedTemplatesIds.contains(old.id)
	}.map(\.form)
		.compactMap {
			extract(case: MetaForm.template, from: $0)
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
	forms = IdentifiedArray.init(wrap(IdentifiedArray(result)))
}
