import ComposableArchitecture
import Model
import Overture

func transformBack(_ journeyMode: JourneyMode,
									 _ forms: [MetaFormAndStatus],
									 _ checkInContainerState: inout CheckInContainerState) {
	forms.filter(
		with(journeyMode, filterMetaFormsByJourneyMode)
	).forEach {
		unwrap(&checkInContainerState, $0)
	}
}

func transformInFormsArray(_ journeyMode: JourneyMode,
													 _ state: CheckInContainerState) -> [MetaFormAndStatus] {
	state.stepTypes
		.filter(with(journeyMode, filterStepType))
		.reduce(into: [MetaFormAndStatus]()) {
			$0.append(contentsOf:
				with($1, (with(state, curry(wrapForm(_:_:))))))
	}
	.sorted(by: their(pipe(get(\.form), stepType(form:), get(\.order))))
}

func wrapForm(_ state: CheckInContainerState,
							_ stepType: StepType) -> [MetaFormAndStatus] {
	switch stepType {
	case .patientdetails:
		let form = MetaForm.patientDetails(state.patientDetails)
		return [MetaFormAndStatus(form, state.patientDetailsCompleted)]
	case .medicalhistory:
		let form = MetaForm.template(state.medHistory)
		return [MetaFormAndStatus(form, state.medHistoryCompleted)]
	case .consents:
		return state.runningConsents.map {
			let form = MetaForm.template($0.value)
			guard let status = state.consentsCompleted[$0.value.id] else { fatalError() }
			return MetaFormAndStatus(form, status)
		}
	case .checkpatient:
		let form = MetaForm.checkPatient(state.checkPatient)
		return [MetaFormAndStatus(form, state.checkPatientCompleted)]
	case .treatmentnotes:
		return state.runningTreatmentForms.map {
			let form = MetaForm.template($0.value)
			guard let status = state.treatmentFormsCompleted[$0.value.id] else { fatalError() }
			return MetaFormAndStatus(form, status)
		}
	case .prescriptions:
		return state.runningPrescriptions.map {
			let form = MetaForm.template($0.value)
			guard let status = state.prescriptionsCompleted[$0.value.id] else { fatalError() }
			return MetaFormAndStatus(form, status)
		}
	case .photos:
		return [] //TODO
	case .recalls:
		let form = MetaForm.recall(state.recall)
		return [MetaFormAndStatus(form, state.recallCompleted)]
	case .aftercares:
		let form = MetaForm.aftercare(state.aftercare)
		return [MetaFormAndStatus(form, state.aftercareCompleted)]
	case .patientComplete:
		let form = MetaForm.patientComplete(state.patientComplete)
		return [MetaFormAndStatus(form, false)]
	}
}

func unwrap(_ state: inout CheckInContainerState,
						_ metaFormAndStatus: MetaFormAndStatus) {
	let metaForm = metaFormAndStatus.form
	let isComplete = metaFormAndStatus.isComplete
	switch stepType(form: metaForm) {
	case .patientdetails:
		state.patientDetails = extract(case: MetaForm.patientDetails, from: metaForm)!
		state.patientDetailsCompleted = isComplete
	case .medicalhistory:
		state.medHistory = extract(case: MetaForm.template, from: metaForm)!
		state.medHistoryCompleted = isComplete
	case .consents:
		let consent = extract(case: MetaForm.template, from: metaForm)!
		state.runningConsents[consent.id] = consent
		state.consentsCompleted[consent.id] = isComplete
	case .checkpatient:
		state.checkPatientCompleted = isComplete
	case .treatmentnotes:
		let treatmentnote = extract(case: MetaForm.template, from: metaForm)!
		state.runningTreatmentForms[treatmentnote.id] = treatmentnote
		state.treatmentFormsCompleted[treatmentnote.id] = isComplete
	case .prescriptions:
		let prescription = extract(case: MetaForm.template, from: metaForm)!
		state.runningPrescriptions[prescription.id] = prescription
		state.prescriptionsCompleted[prescription.id] = isComplete
	case .photos:
		return
	case .recalls:
		state.recall = extract(case: MetaForm.recall, from: metaForm)!
		state.recallCompleted = isComplete
	case .aftercares:
		state.aftercare = extract(case: MetaForm.aftercare, from: metaForm)!
		state.aftercareCompleted = isComplete
	case .patientComplete:
		state.patientComplete = extract(case: MetaForm.patientComplete, from: metaForm)!
	}
}

func updateWithKeepingOld(runningForms: inout [Int: FormTemplate],
													finalSelectedTemplatesIds: [Int],
													allTemplates: [Int: FormTemplate]) {
	let oldWithData = runningForms.filter { old in
		finalSelectedTemplatesIds.contains(old.key)
	}
	let new = selected(allTemplates, finalSelectedTemplatesIds)
	runningForms = oldWithData.merging(new,
																		 uniquingKeysWith: { (old, _) in
																			return old
	})
}

func updateWithKeepingOld(formsCompleted: inout [Int: Bool],
													finalSelectedTemplatesIds: [Int]) {
	let oldWithDataCompleted = formsCompleted.filter { old in
		finalSelectedTemplatesIds.contains(old.key)
	}
	let newCompleted = finalSelectedTemplatesIds.reduce(into: [Int: Bool]()) {
		$0[$1] = false
	}
	formsCompleted = oldWithDataCompleted.merging(newCompleted,
																								uniquingKeysWith: {
																									(old, _) in
																									return old
	})
}
