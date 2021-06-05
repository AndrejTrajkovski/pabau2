import SwiftUI
import Util
import ComposableArchitecture
import Model
import SharedComponents

public struct PatientDetailsParentState: Equatable {
	
	public init () { }
	
	var patientDetails: ClientBuilder?
	var loadingState: LoadingState = .initial
	public var stepStatus: StepStatus = .pending
}

public enum PatientDetailsParentAction: Equatable {
	case patientDetails(PatientDetailsAction)
	case gotGETResponse(Result<ClientBuilder, RequestError>)
	case gotPOSTResponse(Result<FilledFormData.ID, RequestError>)
	case errorView(ErrorViewAction)
}

public struct PatientDetailsParent: View {
	
	public init(store: Store<PatientDetailsParentState, PatientDetailsParentAction>) {
		self.store = store
	}
	
	let store: Store<PatientDetailsParentState, PatientDetailsParentAction>
	
	public var body: some View {
		IfLetStore(store.scope(state: { $0.patientDetails },
							   action: { .patientDetails($0) }),
				   then: PatientDetailsForm.init(store:),
				   else: {
						
				   })
	}
}
