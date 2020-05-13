public enum MetaForm: Equatable, Hashable, CustomDebugStringConvertible {
	
	public var debugDescription: String {
		switch self {
		case .patientDetails:
			return "PATIENT DETAILS"
		case .template(let template):
			return template.debugDescription
		case .aftercare:
			return "AFTERCARE"
		case .patientComplete:
			return "COMPLETE"
		}
	}
	
	init(_ patD: PatientDetails) {
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
