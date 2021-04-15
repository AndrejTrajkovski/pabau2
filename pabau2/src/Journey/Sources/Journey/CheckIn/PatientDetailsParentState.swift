import Model
import Form

struct PatientDetailsParentState: Equatable {
	var editClient: AddClientState
	var status: StepStatus
}
