import Form
import Model

public enum StepState: Equatable, Identifiable {
	public var id: Step.ID {
		switch self {
		case .patientDetails(let pds):
			return pds.id
		case .htmlForm(let html):
			return  html.id
		}
	}
	
	case patientDetails(PatientDetailsParentState)
	case htmlForm(HTMLFormStepContainerState)
}
