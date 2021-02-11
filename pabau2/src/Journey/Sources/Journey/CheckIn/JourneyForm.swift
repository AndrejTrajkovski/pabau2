import Form
import Model
import Util
import SwiftUI
import ComposableArchitecture

public protocol JourneyForm {
//	var canProceed: Bool { get }
	var apiPath: String { get }
}

extension HTMLForm: JourneyForm {
	public var apiPath: String { "forms/\(self.id)" }
}

extension PatientDetails: JourneyForm {
	public var apiPath: String { "patientDetails/\(self.id)" }
}

public struct JourneyFormInfo<Form: JourneyForm>: Equatable, Identifiable where Form: Equatable & Identifiable {

	public init(id: Form.ID, form: Form, status: Bool, loadingState: LoadingState) {
		self.id = id
		self.form = form
		self.status = status
		self.loadingState = loadingState
	}

	public let id: Form.ID
	public var form: Form
	public var status: Bool
	public var loadingState: LoadingState
}

public enum JourneyFormRequestsAction<Form> where Form: JourneyForm & Identifiable {
	case postResponse(Result<Form, RequestError>)
	case getResponse(Result<Form, RequestError>)
	case getForm
}

struct JourneyFormReducer<Form: JourneyForm> where Form: Equatable & Identifiable {
	let reducer: Reducer<JourneyFormInfo<Form>, JourneyFormRequestsAction<Form>, Any> = .init { state, action, env in
		switch action {
		
		case .getForm:
			break
		case .getResponse(let result):
			switch result {
			case .success(let form):
				state.form = form
				state.loadingState = .gotSuccess
			case .failure(let error):
				state.loadingState = .gotError(error)
			}
		default:
			break
		}
		
		return .none
	}
}

struct JourneyFormRequests<Form, Content>: View where Form: Equatable & JourneyForm & Identifiable, Content: View {
	
	let store: Store<JourneyFormInfo<Form>, JourneyFormRequestsAction<Form>>
	let content: () -> Content
	
	var body: some View {
		WithViewStore(store) { viewStore in
			content()
				.loadingView(.constant(viewStore.state.loadingState.isLoading))
		}
	}
}

//struct JourneyFormView<Form, Content>: View where Form: Equatable & JourneyForm & Identifiable, Content: View {
//
//	let store: Store<Form, Any>
//	let content: () -> Content
//
//	var body: some View {
//		WithViewStore(store) { viewStore in
//			content()
//				.loadingView(.constant(viewStore.state.loadingState.isLoading))
//		}
//	}
//}
