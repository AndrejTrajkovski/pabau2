import Overture
import Model

func flatten<T: Identifiable>(_ list: [T]) -> [T.ID: T] {
	Dictionary(uniqueKeysWithValues: Array(zip(list.map(\.id), list)))
}

let filterMetaFormsByJourneyMode =
	flip(
		pipe(
			get(\MetaFormAndStatus.form),
			stepType(form:),
			flip(curry(isIn(_:_:))
		)
	)
)

func isIn(_ journeyMode: JourneyMode, _ stepType: StepType) -> Bool {
	stepToModeMap(stepType) == journeyMode
}

let filterBy = curry(isIn(_:_:))

func stepToModeMap(_ stepType: StepType) -> JourneyMode {
	switch stepType {
	case .patientdetails: return .patient
	case .medicalhistory: return .patient
	case .consents: return .patient
	case .patientComplete: return .patient
	case .checkpatient: return .doctor
	case .treatmentnotes: return .doctor
	case .prescriptions: return .doctor
	case .photos: return .doctor
	case .recalls: return .doctor
	case .aftercares: return .doctor
	}
}

func stepType(form: MetaForm) -> StepType {
	switch form {
	case .aftercare:
		return .aftercares
	case .template(let template):
		return stepType(type: template.formType)
	case .patientDetails:
		return .patientdetails
	case .patientComplete:
		return .patientComplete
	case .checkPatient:
		return .checkpatient
	case .recall:
		return .recalls
	}
}

func stepType(type: FormType) -> StepType {
	switch type {
	case .consent:
		return .consents
	case .history:
		return .medicalhistory
	case .prescription:
		return .prescriptions
	case .treatment:
		return .treatmentnotes
	}
}

let filterStepType = filterBy

func selected(_ templates: [Int: FormTemplate], _ selectedIds: [Int]) -> [Int: FormTemplate] {
	templates.filter { selectedIds.contains($0.key) }
}

let formTemplatesAllFalse: ([Int: FormTemplate]) -> [Int: Bool] = { state in
	return allFalseCompleted(state.map(\.key))
}

func allFalseCompleted(_ ids: [Int]) -> [Int: Bool] {
	ids.reduce(into: [Int: Bool]()) {
		$0[$1] = false
	}
}
