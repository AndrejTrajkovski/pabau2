import Form

enum StepAction {
	case patientDetails(PatientDetailsParentAction)
	case htmlForm(HTMLFormStepContainerAction)
}
