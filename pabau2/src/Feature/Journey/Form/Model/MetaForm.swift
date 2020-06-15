import Model

public enum MetaForm: Equatable {
	var canProceed: Bool {
		switch self {
		case .template(let template):
			return template.canProceed
		case .patientDetails(let patDetails):
			return patDetails.canProceed
		case .aftercare:
			return true
		case .patientComplete:
			return true
		case .checkPatient:
			return true
		case .photos(let photosState):
			return !photosState.photos.isEmpty
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
	case checkPatient(CheckPatient)
	case photos(PhotosState)

	var title: String {
		switch self {
		case .patientDetails:
			return "ENTER PATIENT DETAILS"
		case .template(let template):
			return title(template: template)
		case .aftercare:
			return "AFTERCARE"
		case .patientComplete:
			return "COMPLETE"
		case .checkPatient:
			return "CHECK PATIENT DETAILS"
		case .photos:
			return "PHOTOS"
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
