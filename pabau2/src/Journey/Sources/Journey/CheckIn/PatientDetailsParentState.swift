import Model
import Form
import Util

struct PatientDetailsParentState: Equatable {
	let clientId: Client.ID
	var getClientLS: LoadingState
	var editClient: AddClientState?
	var status: StepStatus
	
	init(clientId: Client.ID,
		 status: StepStatus) {
		self.clientId = clientId
		self.getClientLS = .initial
		self.editClient = nil
		self.status = status
	}
}
