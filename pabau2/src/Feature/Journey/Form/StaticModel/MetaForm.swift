import Model

public enum MetaForm: Equatable, Hashable {

	init(_ patD: PatientDetails) {
//		guard let patD = patD else { return nil }
		self = .patientDetails(patD)
	}

	init(_ aftercare: Aftercare) {
		self = .aftercare(aftercare)
	}

	init(_ template: FormTemplate) {
		self = .template(template)
	}

	init(_ patientComplete: PatientComplete) {
		self = .patientComplete(patientComplete)
	}

	case patientDetails(PatientDetails)
	case aftercare(Aftercare)
	case template(FormTemplate)
	case patientComplete(PatientComplete)
	case checkPatient(CheckPatientForm)
	case recall(Recall)

	var title: String {
		switch self {
		case .patientDetails:
			return "PATIENT DETAILS"
		case .template(let template):
			return title(template: template)
		case .aftercare:
			return "AFTERCARE"
		case .patientComplete:
			return "COMPLETE"
		case .checkPatient:
			return "CHECK PATIENT"
		case .recall:
			return "RECALL"
		}
	}

	private func title(template: FormTemplate) -> String {
		switch template.formType {
		case .consent, .treatment:
			return template.name
		case .history:
			return "HISTORY"
		case .prescription:
			return "PRESCRIPTION"
		}
	}
}
